const admin = require("firebase-admin");
const functions = require("firebase-functions");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Admin user ID (same as in your Flutter app)
const ADMIN_USER_ID = "yzPSwbiWTgXywHPVyBXhjfZGjR42";

// Cloud Function to send admin notification when a new order is created
exports.sendAdminNotification = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const orderId = context.params.orderId;
    const orderData = snap.data();

    if (!orderData) {
      console.error("No order data found for order:", orderId);
      return;
    }

    try {
      console.log("🔔 New order detected:", orderId);
      
      // Get admin FCM token from Firestore
      const db = admin.firestore();
      const adminTokenDoc = await db.collection("admin_tokens").doc(ADMIN_USER_ID).get();
      
      if (!adminTokenDoc.exists) {
        console.warn("❌ Admin token not found - admin may not be logged in");
        return;
      }

      const adminTokenData = adminTokenDoc.data();
      const adminToken = adminTokenData.token;
      if (!adminToken) {
        console.warn("❌ Admin token is empty");
        return;
      }

      // Extract order details
      const userName = orderData.userName || "Unknown Customer";
      const total = orderData.total || 0;
      const items = orderData.items || [];
      const itemCount = items.length;
      const address = orderData.address || {};
      const paymentMethod = orderData.paymentMethod || "Unknown";

      // Create notification payload
      const notification = {
        title: "🎉 New Order Received!",
        body: `${userName} ordered ${itemCount} items - EGP ${total.toFixed(2)}`
      };

      const data = {
        orderId: orderId,
        type: "new_order",
        customerName: userName,
        orderTotal: total.toString(),
        itemCount: itemCount.toString(),
        paymentMethod: paymentMethod,
        timestamp: new Date().toISOString(),
        // Include address info if available
        customerArea: address.area || "Unknown",
        customerCity: address.city || "Unknown"
      };

      // Send the notification
      const message = {
        notification: notification,
        data: data,
        token: adminToken,
        android: {
          priority: "high",
          notification: {
            channelId: "admin_orders",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: "ic_notification",
            color: "#FF6B35"
          }
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body
              },
              sound: "default",
              badge: 1,
              category: "admin_order"
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Admin notification sent successfully:", response);

      // Also store the notification in Firestore for history
      await db.collection("admin_notifications").add({
        title: notification.title,
        body: notification.body,
        orderId: orderId,
        type: "new_order",
        customerName: userName,
        orderTotal: total,
        itemCount: itemCount,
        paymentMethod: paymentMethod,
        timestamp: new Date().toISOString(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
        sentAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log("✅ Admin notification stored in Firestore");

    } catch (error) {
      console.error("❌ Error sending admin notification:", error);
      
      // Store failed notification attempt
      try {
        const db = admin.firestore();
        await db.collection("admin_notifications").add({
          title: "Failed to send notification",
          body: `Error sending notification for order ${orderId}`,
          orderId: orderId,
          type: "notification_error",
          error: error.message || "Unknown error",
          timestamp: new Date().toISOString(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          failed: true
        });
      } catch (storeError) {
        console.error("❌ Error storing failed notification:", storeError);
      }
    }
  });

// Cloud Function to update admin token
exports.updateAdminToken = functions.firestore
  .document("admin_tokens/{userId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const tokenData = snap.data();

    if (userId === ADMIN_USER_ID && tokenData) {
      console.log("🔑 Admin token updated:", tokenData.token.substring(0, 20) + "...");
    }
  });

// Cloud Function to clean up old notifications (runs when triggered)
exports.cleanupOldNotifications = functions.firestore
  .document("maintenance/cleanup_trigger")
  .onCreate(async () => {
    try {
      const db = admin.firestore();
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const oldNotifications = await db
        .collection("admin_notifications")
        .where("createdAt", "<", thirtyDaysAgo)
        .get();

      const batch = db.batch();
      oldNotifications.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`✅ Cleaned up ${oldNotifications.docs.length} old notifications`);
    } catch (error) {
      console.error("❌ Error cleaning up old notifications:", error);
    }
  }); 