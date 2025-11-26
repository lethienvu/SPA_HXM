/**
 * PARADISE HR - MODAL SYSTEM
 * Modern modal component với glassmorphism effects
 * Supports: Info, Success, Warning, Error, Custom modals
 */

class Modal {
  constructor() {
    this.activeModals = new Set();
    this.modalStack = [];
    this.init();
  }

  init() {
    // Tạo modal container nếu chưa có
    if (!document.getElementById("modal-root")) {
      const modalRoot = document.createElement("div");
      modalRoot.id = "modal-root";
      modalRoot.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                z-index: var(--z-modal-backdrop, 1040);
            `;
      document.body.appendChild(modalRoot);
    }

    // Xử lý ESC key
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && this.modalStack.length > 0) {
        this.close(this.modalStack[this.modalStack.length - 1]);
      }
    });
  }

  /**
   * Tạo modal cơ bản
   * @param {Object} options - Cấu hình modal
   */
  create(options = {}) {
    const defaults = {
      title: "",
      content: "",
      size: "md", // sm, md, lg, xl
      type: "default", // success, warning, error, info
      showCloseButton: true,
      backdrop: true,
      keyboard: true,
      animation: true,
      customClass: "",
      onShow: null,
      onHide: null,
      onConfirm: null,
      onCancel: null,
    };

    const config = { ...defaults, ...options };
    const modalId =
      "modal-" + Date.now() + "-" + Math.random().toString(36).substr(2, 9);

    // Tạo backdrop
    const backdrop = this.createBackdrop(modalId, config);

    // Tạo modal container
    const modal = this.createModalContainer(modalId, config);

    // Tạo modal content
    const content = this.createModalContent(config);
    modal.appendChild(content);

    backdrop.appendChild(modal);
    document.getElementById("modal-root").appendChild(backdrop);

    // Xử lý events
    this.setupModalEvents(modalId, config);

    // Animation và show
    if (config.animation) {
      this.animateShow(modalId);
    } else {
      this.showModal(modalId);
    }

    // Callback onShow
    if (config.onShow) {
      setTimeout(() => config.onShow(modalId), 100);
    }

    return modalId;
  }

  createBackdrop(modalId, config) {
    const backdrop = document.createElement("div");
    backdrop.id = `${modalId}-backdrop`;
    backdrop.className = "modal-backdrop";
    backdrop.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--bg-overlay, rgba(0, 0, 0, 0.5));
            backdrop-filter: var(--blur-sm, blur(4px));
            -webkit-backdrop-filter: var(--blur-sm, blur(4px));
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            pointer-events: auto;
            transition: opacity var(--duration-normal, 0.3s) var(--ease-out, ease-out);
            z-index: var(--z-modal-backdrop, 1040);
        `;

    if (config.backdrop) {
      backdrop.addEventListener("click", (e) => {
        if (e.target === backdrop) {
          this.close(modalId);
        }
      });
    }

    return backdrop;
  }

  createModalContainer(modalId, config) {
    const modal = document.createElement("div");
    modal.id = modalId;
    modal.className = `modal modal-${config.size} ${config.customClass}`;

    const sizeStyles = {
      sm: "max-width: 400px;",
      md: "max-width: 600px;",
      lg: "max-width: 800px;",
      xl: "max-width: 1200px;",
    };

    modal.style.cssText = `
            background: var(--glass-primary, rgba(255, 255, 255, 0.95));
            backdrop-filter: var(--blur-lg, blur(20px));
            -webkit-backdrop-filter: var(--blur-lg, blur(20px));
            border: 1px solid var(--glass-border-medium, rgba(255, 255, 255, 0.3));
            border-radius: var(--radius-modal, 12px);
            box-shadow: var(--shadow-glass-lg, 0 25px 50px -12px rgba(0, 0, 0, 0.25));
            ${sizeStyles[config.size]}
            width: 90vw;
            max-height: 90vh;
            overflow: hidden;
            transform: scale(0.95) translateY(20px);
            transition: all var(--duration-normal, 0.3s) var(--ease-apple, cubic-bezier(0.25, 0.1, 0.25, 1));
            position: relative;
        `;

    return modal;
  }

  createModalContent(config) {
    const content = document.createElement("div");
    content.className = "modal-content";

    // Header
    const header = this.createModalHeader(config);
    if (header) content.appendChild(header);

    // Body
    const body = this.createModalBody(config);
    content.appendChild(body);

    // Footer
    const footer = this.createModalFooter(config);
    if (footer) content.appendChild(footer);

    return content;
  }

  createModalHeader(config) {
    if (!config.title && !config.showCloseButton) return null;

    const header = document.createElement("div");
    header.className = "modal-header";
    header.style.cssText = `
            padding: var(--space-6);
            border-bottom: 1px solid var(--glass-border-light);
            display: flex;
            align-items: center;
            justify-content: space-between;
        `;

    if (config.title) {
      const title = document.createElement("h3");
      title.className = "modal-title";
      title.textContent = config.title;
      title.style.cssText = `
                margin: 0;
                font-size: var(--text-xl);
                font-weight: var(--font-semibold);
                color: var(--text-primary);
            `;

      // Thêm icon theo type
      if (config.type !== "default") {
        const icon = this.createTypeIcon(config.type);
        title.insertBefore(icon, title.firstChild);
      }

      header.appendChild(title);
    }

    if (config.showCloseButton) {
      const closeBtn = document.createElement("button");
      closeBtn.className = "modal-close-btn";
      closeBtn.innerHTML = ''<i class="bi bi-x-lg"></i>'';
      closeBtn.style.cssText = `
                background: none;
                border: none;
                color: var(--text-secondary);
                font-size: var(--text-lg);
                cursor: pointer;
                padding: var(--space-2);
                border-radius: var(--radius-sm);
                transition: all var(--duration-fast) var(--ease-out);
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
            `;

      closeBtn.addEventListener("mouseenter", () => {
        closeBtn.style.background = "var(--neutral-200)";
        closeBtn.style.color = "var(--text-primary)";
      });

      closeBtn.addEventListener("mouseleave", () => {
        closeBtn.style.background = "none";
        closeBtn.style.color = "var(--text-secondary)";
      });

      header.appendChild(closeBtn);
    }

    return header;
  }

  createModalBody(config) {
    const body = document.createElement("div");
    body.className = "modal-body";
    body.style.cssText = `
            padding: var(--space-6);
            max-height: 60vh;
            overflow-y: auto;
        `;

    if (typeof config.content === "string") {
      body.innerHTML = config.content;
    } else if (config.content instanceof HTMLElement) {
      body.appendChild(config.content);
    }

    return body;
  }

  createModalFooter(config) {
    if (!config.onConfirm && !config.onCancel) return null;

    const footer = document.createElement("div");
    footer.className = "modal-footer";
    footer.style.cssText = `
            padding: var(--space-4) var(--space-6) var(--space-6);
            border-top: 1px solid var(--glass-border-light);
            display: flex;
            gap: var(--space-3);
            justify-content: flex-end;
        `;

    if (config.onCancel) {
      const cancelBtn = document.createElement("button");
      cancelBtn.className = "btn btn-secondary btn-md";
      cancelBtn.textContent = config.cancelText || "Hủy";
      footer.appendChild(cancelBtn);
    }

    if (config.onConfirm) {
      const confirmBtn = document.createElement("button");
      confirmBtn.className = `btn btn-${this.getButtonType(
        config.type
      )} btn-md`;
      confirmBtn.textContent = config.confirmText || "Xác nhận";
      footer.appendChild(confirmBtn);
    }

    return footer;
  }

  createTypeIcon(type) {
    const icon = document.createElement("i");
    icon.style.marginRight = "var(--space-2)";

    const iconMap = {
      success: "bi bi-check-circle text-success",
      warning: "bi bi-exclamation-triangle text-warning",
      error: "bi bi-x-circle text-error",
      info: "bi bi-info-circle text-info",
    };

    icon.className = iconMap[type] || "";
    return icon;
  }

  getButtonType(modalType) {
    const typeMap = {
      success: "primary",
      warning: "warning",
      error: "danger",
      info: "primary",
      default: "primary",
    };
    return typeMap[modalType] || "primary";
  }

  setupModalEvents(modalId, config) {
    const backdrop = document.getElementById(`${modalId}-backdrop`);
    const modal = document.getElementById(modalId);

    // Close button
    const closeBtn = modal.querySelector(".modal-close-btn");
    if (closeBtn) {
      closeBtn.addEventListener("click", () => this.close(modalId));
    }

    // Footer buttons
    const cancelBtn = modal.querySelector(".modal-footer .btn-secondary");
    const confirmBtn = modal.querySelector(
      ".modal-footer .btn:not(.btn-secondary)"
    );

    if (cancelBtn && config.onCancel) {
      cancelBtn.addEventListener("click", () => {
        if (config.onCancel(modalId) !== false) {
          this.close(modalId);
        }
      });
    }

    if (confirmBtn && config.onConfirm) {
      confirmBtn.addEventListener("click", () => {
        if (config.onConfirm(modalId) !== false) {
          this.close(modalId);
        }
      });
    }

    // Thêm vào stack
    this.activeModals.add(modalId);
    this.modalStack.push(modalId);
  }

  animateShow(modalId) {
    const backdrop = document.getElementById(`${modalId}-backdrop`);
    const modal = document.getElementById(modalId);

    requestAnimationFrame(() => {
      backdrop.style.opacity = "1";
      modal.style.transform = "scale(1) translateY(0)";
    });
  }

  showModal(modalId) {
    const backdrop = document.getElementById(`${modalId}-backdrop`);
    backdrop.style.opacity = "1";
  }

  /**
   * Đóng modal
   */
  close(modalId) {
    const backdrop = document.getElementById(`${modalId}-backdrop`);
    const modal = document.getElementById(modalId);

    if (!backdrop || !modal) return;

    // Animation hide
    backdrop.style.opacity = "0";
    modal.style.transform = "scale(0.95) translateY(20px)";

    setTimeout(() => {
      backdrop.remove();
      this.activeModals.delete(modalId);
      this.modalStack = this.modalStack.filter((id) => id !== modalId);
    }, 300);
  }

  /**
   * Đóng tất cả modal
   */
  closeAll() {
    this.modalStack.forEach((modalId) => this.close(modalId));
  }

  /**
   * Success Modal
   */
  success(options = {}) {
    return this.create({
      type: "success",
      title: options.title || "Thành công",
      content: options.content || "",
      confirmText: "OK",
      onConfirm: options.onConfirm || (() => true),
      ...options,
    });
  }

  /**
   * Warning Modal
   */
  warning(options = {}) {
    return this.create({
      type: "warning",
      title: options.title || "Cảnh báo",
      content: options.content || "",
      confirmText: "OK",
      onConfirm: options.onConfirm || (() => true),
      ...options,
    });
  }

  /**
   * Error Modal
   */
  error(options = {}) {
    return this.create({
      type: "error",
      title: options.title || "Lỗi",
      content: options.content || "",
      confirmText: "OK",
      onConfirm: options.onConfirm || (() => true),
      ...options,
    });
  }

  /**
   * Info Modal
   */
  info(options = {}) {
    return this.create({
      type: "info",
      title: options.title || "Thông tin",
      content: options.content || "",
      confirmText: "OK",
      onConfirm: options.onConfirm || (() => true),
      ...options,
    });
  }

  /**
   * Confirm Dialog
   */
  confirm(options = {}) {
    return this.create({
      type: "warning",
      title: options.title || "Xác nhận",
      content:
        options.content || "Bạn có chắc chắn muốn thực hiện hành động này?",
      confirmText: options.confirmText || "Xác nhận",
      cancelText: options.cancelText || "Hủy",
      onConfirm: options.onConfirm || (() => true),
      onCancel: options.onCancel || (() => true),
      ...options,
    });
  }
}

// Export để sử dụng trong SPA framework
window.Modal = Modal;

// Tạo instance global
window.modal = new Modal();
