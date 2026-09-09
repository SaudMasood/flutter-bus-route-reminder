const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");

const { onSchedule } =
  require("firebase-functions/v2/scheduler");

const { initializeApp } =
  require("firebase-admin/app");

const { getFirestore } =
  require("firebase-admin/firestore");

const { getMessaging } =
  require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();


// 1. NEW BUS → NOTIFY ALL USERS

exports.notifyNewBus = onDocumentCreated(
  "buses/{busId}",
  async (event) => {
    const bus = event.data.data();

    await messaging.send({
      topic: "all_users",

      notification: {
        title: "New Bus Route 🚌",
        body: `Bus ${bus.busNumber} added. ${bus.route}`,
      },

      data: {
        busId: event.params.busId,
      },
    });

    console.log("New bus notification sent to all users");
  }
);



// 2. UPDATED BUS → NOTIFY ALL USERS

exports.notifyUpdatedBus = onDocumentUpdated(
  "buses/{busId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    await messaging.send({
      topic: "all_users",

      notification: {
        title: "Bus Route Updated 🚌",
        body: `Bus ${after.busNumber} route has been updated.`,
      },

      data: {
        busId: event.params.busId,
      },
    });

    console.log("Bus update notification sent to all users");
  }
);


// 3. PERSONAL BUS REMINDER → ONE USER


exports.sendBusReminders = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "Asia/Karachi",
  },
  async () => {
    const now = new Date();

    const snapshot = await db
      .collection("reminders")
      .where("sent", "==", false)
      .get();

    console.log(
      "Reminders found:",
      snapshot.size
    );

    for (const doc of snapshot.docs) {
      const reminder = doc.data();

      if (!reminder.reminderTime) {
        continue;
      }

      const reminderTime =
        reminder.reminderTime.toDate();

      // Reminder time has not arrived yet
      if (reminderTime > now) {
        continue;
      }

      // Get user
      const userDoc = await db
        .collection("users")
        .doc(reminder.userId)
        .get();

      if (!userDoc.exists) {
        console.log(
          "User not found:",
          reminder.userId
        );
        continue;
      }

      const user = userDoc.data();

      // Check FCM token
      if (!user.fcmToken) {
        console.log(
          "FCM token missing:",
          reminder.userId
        );
        continue;
      }

      // Send notification to ONE user
      await messaging.send({
        token: user.fcmToken,

        notification: {
          title: "Bus Reminder 🚌",
          body: "Your bus reminder time has arrived.",
        },

        data: {
          busId: reminder.busId,
          reminderId: doc.id,
        },
      });

      // Mark reminder as sent
      await doc.ref.update({
        sent: true,
      });

      console.log(
        "Personal reminder sent:",
        doc.id
      );
    }
  }
);