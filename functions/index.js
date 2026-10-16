
const { onDocumentCreated, onDocumentUpdated } =
  require("firebase-functions/v2/firestore");

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

function normalizeRole(user) {
  return String(
    user.role || user.userType || user.accountType || ""
  ).trim().toLowerCase();
}

async function sendToUsers(users, title, body, data = {}) {
  const tokens = [];

  for (const userDoc of users) {
    const user = userDoc.data();
    const userTokens = user.fcmTokens;

    if (Array.isArray(userTokens)) {
      tokens.push(...userTokens.filter(
        (token) => typeof token === "string" && token.length > 0
      ));
    }
  }

  const uniqueTokens = [...new Set(tokens)];

  if (uniqueTokens.length === 0) {
    console.log("No FCM tokens found for notification:", title);
    return;
  }

  // FCM multicast requests support up to 500 tokens per request.
  for (let i = 0; i < uniqueTokens.length; i += 500) {
    const batch = uniqueTokens.slice(i, i + 500);

    const response = await messaging.sendEachForMulticast({
      tokens: batch,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([key, value]) => [
          key,
          String(value),
        ])
      ),
      webpush: {
        notification: {
          icon: "/icons/Icon-192.png",
        },
      },
    });

    console.log(
      `Notification sent: ${response.successCount} successful, ` +
      `${response.failureCount} failed`
    );
  }
}

async function getUsersByRoles(roles) {
  const snapshot = await db.collection("users").get();

  return snapshot.docs.filter((doc) =>
    roles.includes(normalizeRole(doc.data()))
  );
}

// NEW ORDER: notify Restaurant Admin and Kitchen Staff.
exports.notifyNewOrder = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const order = event.data?.data();
    if (!order) return;

    const orderId = event.params.orderId;
    const roles = await getUsersByRoles([
      "admin",
      "restaurant admin",
      "kitchen staff",
      "kitchen",
    ]);

    const recipients = roles.filter((doc) => {
      const role = normalizeRole(doc.data());
      return [
        "admin",
        "restaurant admin",
        "kitchen staff",
        "kitchen",
      ].includes(role);
    });

    await sendToUsers(
      recipients,
      "New AFZ Restaurant Order",
      `Order ${orderId.slice(0, 8).toUpperCase()} received — Rs. ${
        order.total ?? 0
      }`,
      {
        type: "new_order",
        orderId,
        status: String(order.status || "Pending"),
      }
    );
  }
);

// STATUS CHANGE: notify the customer who placed the order.
exports.notifyOrderStatus = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) return;
    if (before.status === after.status) return;
    if (!after.userId) return;

    const customerDoc = await db
      .collection("users")
      .doc(after.userId)
      .get();

    if (!customerDoc.exists) {
      console.log("Customer profile not found:", after.userId);
      return;
    }

    const status = String(after.status || "Updated");

    await sendToUsers(
      [customerDoc],
      "AFZ Order Update",
      `Your order is now: ${status}`,
      {
        type: "order_status",
        orderId: event.params.orderId,
        status,
      }
    );
  }
);
