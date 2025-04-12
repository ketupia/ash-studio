let CopyToClipboardHook = {
  mounted() {
    this.el.addEventListener("click", () => {
      // console.log("📌 CopyHook clicked!");

      let targetId = this.el.getAttribute("data-target");

      if (!targetId) {
        console.warn("⚠️ CopyHook: Missing 'data-target' attribute on button.");
        this.showNotification("⚠️ CopyHook: No target specified!", "error");
        return;
      }

      let targetElement = document.getElementById(targetId);

      if (!targetElement) {
        console.warn(`⚠️ CopyHook: No element found with ID '${targetId}'.`);
        this.showNotification(
          `❌ Could not find target '${targetId}'`,
          "error"
        );
        return;
      }
      
      let content = targetElement.textContent.trim();
      
      // Try modern clipboard API first
      if (navigator.clipboard && window.ClipboardItem) {
        let blob = new Blob([content], { type: "text/plain" });
        let clipboardItem = new ClipboardItem({ "text/plain": blob });
        // console.log("📌 Copying content:", clipboardItem);

        navigator.clipboard
          .write([clipboardItem])
          // .then(() => {
          //   throw new Error("Simulated copy failure"); // Force failure for testing
          // })
          .then(() => {
            this.showNotification("✅ Command copied!", "success");
          })
          .catch((err) => {
            console.error("❌ Copy failed", err);
            this.showNotification("❌ Copy failed! Please try again.", "error");
            // Try fallback method if modern API fails
            this.fallbackCopyTextToClipboard(content);
          });
      } else {
        // Fallback for browsers without clipboard API support
        this.fallbackCopyTextToClipboard(content);
      }
    });
  },

  fallbackCopyTextToClipboard(text) {
    // Create temporary textarea element
    const textArea = document.createElement("textarea");
    textArea.value = text;
    
    // Make the textarea out of viewport
    textArea.style.position = "fixed";
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";
    document.body.appendChild(textArea);
    
    // For iOS devices
    textArea.contentEditable = true;
    textArea.readOnly = false;
    
    // Select the text
    textArea.focus();
    textArea.select();
    
    let successful = false;
    try {
      // Execute copy command
      successful = document.execCommand("copy");
      if (successful) {
        this.showNotification("✅ Command copied!", "success");
      } else {
        this.showNotification("❌ Copy failed!", "error");
      }
    } catch (err) {
      console.error("❌ copy failed", err);
      this.showNotification("❌ Copy failed! Your browser may not support copying.", "error");
    }
    
    // Cleanup
    document.body.removeChild(textArea);
  },

  showNotification(message, type) {
    let existingNotification = document.getElementById("copy-notification");

    // If a notification is already visible, remove it first
    if (existingNotification) {
      existingNotification.remove();
    }

    let notification = document.createElement("div");
    notification.id = "copy-notification";
    notification.innerText = message;
    notification.style.position = "fixed";
    notification.style.bottom = "20px";
    notification.style.right = "20px";
    notification.style.padding = "10px 15px";
    // notification.style.borderWidth = "medium";
    // notification.style.borderStyle = "5px";
    // notification.style.border = "#000000";

    notification.style.fontSize = "14px";
    notification.style.zIndex = "1000";
    notification.style.opacity = "1";
    notification.style.transition = "opacity 0.5s ease-out";
    notification.style.color = "black";

    // Apply different styles for success and error messages
    if (type === "success") {
      notification.style.border = "2px solid green";
      notification.style.background = "rgba(0, 128, 0, 0.2)"; // Green
    } else if (type === "error") {
      notification.style.border = "2px solid red";
      notification.style.background = "rgba(255, 0, 0, 0.2)"; // Red
    }

    document.body.appendChild(notification);

    // Auto-dismiss after 2 seconds
    setTimeout(() => {
      notification.style.opacity = "0";
      setTimeout(() => notification.remove(), 500); // Remove element after fade-out
    }, 2000);
  },
};

export default CopyToClipboardHook;
