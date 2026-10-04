const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

// ============================================================
// NOTIFICATION AUTOMATIQUE APRÈS UN PAIEMENT
// ============================================================

exports.createPaymentNotification = onDocumentCreated(
  "payments/{paymentId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      console.log("❌ Aucun document payment trouvé.");
      return;
    }

    const payment = snapshot.data();

    // ----------------------------------------------------------
    // RÉCUPÉRER LES INFORMATIONS
    // ----------------------------------------------------------

    const amount = payment.amount;
    const userId = payment.userId;

    if (!amount || !userId) {
      console.log(
        "❌ Paiement incomplet : amount ou userId manquant."
      );
      return;
    }

    // ----------------------------------------------------------
    // CRÉER LA NOTIFICATION
    // ----------------------------------------------------------

    await admin.firestore().collection("notifications").add({
      userId: userId,
      title: "Recharge réussie",
      message:
          `Votre compte a été rechargé de ${Number(amount).toFixed(0)} DA.`,
      type: "paiement",
      lu: false,
      date_envoi: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `✅ Notification créée pour une recharge de ${amount} DA`
    );
  }
);