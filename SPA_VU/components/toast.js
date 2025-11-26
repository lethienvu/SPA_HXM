/**
 * PARADISE HR - NOTIFICATION TOAST SYSTEM
 * Modern toast notifications với glassmorphism effects
 * Supports: Success, Warning, Error, Info notifications
 */

class Toast {
  constructor() {
    this.toasts = new Map();
    this.toastQueue = [];
    this.maxToasts = 5;
    this.defaultDuration = 4000;
    this.init();
  }

  init() {
    // Tạo toast container
    if (!document.getElementById("toast-container")) {
      const container = document.createElement("div");
      container.id = "toast-container";
      container.style.cssText = `
                position: fixed;
                top: var(--space-6);
                right: var(--space-6);
                z-index: var(--z-toast);
                display: flex;
                flex-direction: column;
                gap: var(--space-3);
                pointer-events: none;
                max-width: 400px;
                width: 100%;
            `;
      document.body.appendChild(container);
    }

    // Mobile positioning
    this.setupMobileLayout();
  }

  setupMobileLayout() {
    const mediaQuery = window.matchMedia("(max-width: 768px)");

    const updateLayout = (e) => {
      const container = document.getElementById("toast-container");
      if (e.matches) {
        container.style.cssText = `
                    position: fixed;
                    bottom: var(--space-20);
                    left: var(--space-4);
                    right: var(--space-4);
                    top: auto;
                    z-index: var(--z-toast);
                    display: flex;
                    flex-direction: column;
                    gap: var(--space-3);
                    pointer-events: none;
                    max-width: none;
                    width: auto;
                `;
      } else {
        container.style.cssText = `
                    position: fixed;
                    top: var(--space-6);
                    right: var(--space-6);
                    z-index: var(--z-toast);
                    display: flex;
                    flex-direction: column;
                    gap: var(--space-3);
                    pointer-events: none;
                    max-width: 400px;
                    width: 100%;
                `;
      }
    };

    mediaQuery.addListener(updateLayout);
    updateLayout(mediaQuery);
  }

  /**
   * Tạo toast notification
   * @param {Object} options - Cấu hình toast
   */
  show(options = {}) {
    const defaults = {
      title: "",
      message: "",
      type: "info", // success, warning, error, info
      duration: this.defaultDuration,
      persistent: false,
      showCloseButton: true,
      showIcon: true,
      customClass: "",
      onClick: null,
      onClose: null,
      actions: [],
    };

    const config = { ...defaults, ...options };
    const toastId =
      "toast-" + Date.now() + "-" + Math.random().toString(36).substr(2, 9);

    // Kiểm tra queue limit
    if (this.toasts.size >= this.maxToasts) {
      this.removeOldest();
    }

    // Tạo toast element
    const toastElement = this.createToastElement(toastId, config);

    // Thêm vào container
    const container = document.getElementById("toast-container");
    container.appendChild(toastElement);

    // Animation show
    requestAnimationFrame(() => {
      toastElement.style.transform = "translateX(0)";
      toastElement.style.opacity = "1";
    });

    // Thêm vào map
    this.toasts.set(toastId, {
      element: toastElement,
      config: config,
      timer: null,
    });

    // Setup auto hide
    if (!config.persistent && config.duration > 0) {
      this.setupAutoHide(toastId, config.duration);
    }

    // Setup events
    this.setupToastEvents(toastId, config);

    return toastId;
  }

  createToastElement(toastId, config) {
    const toast = document.createElement("div");
    toast.id = toastId;
    toast.className = `toast toast-${config.type} ${config.customClass}`;

    // Base styles
    toast.style.cssText = `
            background: var(--glass-primary);
            backdrop-filter: var(--blur-md);
            -webkit-backdrop-filter: var(--blur-md);
            border: 1px solid var(--glass-border-light);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-glass-md);
            padding: var(--space-4);
            min-height: 64px;
            display: flex;
            align-items: flex-start;
            gap: var(--space-3);
            transform: translateX(100%);
            opacity: 0;
            transition: all var(--duration-normal) var(--ease-apple);
            pointer-events: auto;
            cursor: ${config.onClick ? "pointer" : "default"};
            position: relative;
            overflow: hidden;
        `;

    // Type-specific styling
    this.applyTypeStyles(toast, config.type);

    // Icon
    if (config.showIcon) {
      const icon = this.createToastIcon(config.type);
      toast.appendChild(icon);
    }

    // Content
    const content = this.createToastContent(config);
    toast.appendChild(content);

    // Close button
    if (config.showCloseButton) {
      const closeBtn = this.createCloseButton();
      toast.appendChild(closeBtn);
    }

    // Progress bar cho timed toasts
    if (!config.persistent && config.duration > 0) {
      const progressBar = this.createProgressBar(config.duration);
      toast.appendChild(progressBar);
    }

    // Actions
    if (config.actions && config.actions.length > 0) {
      const actionsContainer = this.createActionsContainer(
        config.actions,
        toastId
      );
      content.appendChild(actionsContainer);
    }

    return toast;
  }

  applyTypeStyles(toast, type) {
    const borderColors = {
      success: "var(--color-success)",
      warning: "var(--color-warning)",
      error: "var(--color-error)",
      info: "var(--color-info)",
    };

    if (borderColors[type]) {
      toast.style.borderLeftColor = borderColors[type];
      toast.style.borderLeftWidth = "4px";
    }
  }

  createToastIcon(type) {
    const iconContainer = document.createElement("div");
    iconContainer.className = "toast-icon";
    iconContainer.style.cssText = `
            flex-shrink: 0;
            width: 32px;
            height: 32px;
            border-radius: var(--radius-full);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: var(--text-lg);
            color: white;
        `;

    const iconMap = {
      success: {
        icon: "bi bi-check-circle-fill",
        bg: "var(--color-success)",
      },
      warning: {
        icon: "bi bi-exclamation-triangle-fill",
        bg: "var(--color-warning)",
      },
      error: {
        icon: "bi bi-x-circle-fill",
        bg: "var(--color-error)",
      },
      info: {
        icon: "bi bi-info-circle-fill",
        bg: "var(--color-info)",
      },
    };

    const typeConfig = iconMap[type] || iconMap.info;
    iconContainer.style.background = typeConfig.bg;
    iconContainer.innerHTML = `<i class="${typeConfig.icon}"></i>`;

    return iconContainer;
  }

  createToastContent(config) {
    const content = document.createElement("div");
    content.className = "toast-content";
    content.style.cssText = `
            flex: 1;
            min-width: 0;
        `;

    if (config.title) {
      const title = document.createElement("div");
      title.className = "toast-title";
      title.textContent = config.title;
      title.style.cssText = `
                font-size: var(--text-sm);
                font-weight: var(--font-semibold);
                color: var(--text-primary);
                margin-bottom: var(--space-1);
            `;
      content.appendChild(title);
    }

    if (config.message) {
      const message = document.createElement("div");
      message.className = "toast-message";
      message.style.cssText = `
                font-size: var(--text-sm);
                color: var(--text-secondary);
                line-height: var(--leading-relaxed);
            `;

      if (typeof config.message === "string") {
        message.textContent = config.message;
      } else {
        message.appendChild(config.message);
      }

      content.appendChild(message);
    }

    return content;
  }

  createCloseButton() {
    const closeBtn = document.createElement("button");
    closeBtn.className = "toast-close-btn";
    closeBtn.innerHTML = ''<i class="bi bi-x"></i>'';
    closeBtn.style.cssText = `
            position: absolute;
            top: var(--space-2);
            right: var(--space-2);
            background: none;
            border: none;
            color: var(--text-muted);
            font-size: var(--text-sm);
            cursor: pointer;
            padding: var(--space-1);
            border-radius: var(--radius-sm);
            transition: all var(--duration-fast) var(--ease-out);
            display: flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
        `;

    closeBtn.addEventListener("mouseenter", () => {
      closeBtn.style.background = "var(--neutral-200)";
      closeBtn.style.color = "var(--text-primary)";
    });

    closeBtn.addEventListener("mouseleave", () => {
      closeBtn.style.background = "none";
      closeBtn.style.color = "var(--text-muted)";
    });

    return closeBtn;
  }

  createProgressBar(duration) {
    const progressContainer = document.createElement("div");
    progressContainer.className = "toast-progress";
    progressContainer.style.cssText = `
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: rgba(0, 0, 0, 0.1);
            overflow: hidden;
        `;

    const progressBar = document.createElement("div");
    progressBar.className = "toast-progress-bar";
    progressBar.style.cssText = `
            height: 100%;
            background: var(--brand-primary);
            width: 100%;
            transform: translateX(-100%);
            animation: toast-progress ${duration}ms linear forwards;
        `;

    // Thêm keyframe animation
    if (!document.getElementById("toast-progress-styles")) {
      const style = document.createElement("style");
      style.id = "toast-progress-styles";
      style.textContent = `
                @keyframes toast-progress {
                    from { transform: translateX(-100%); }
                    to { transform: translateX(0); }
                }
            `;
      document.head.appendChild(style);
    }

    progressContainer.appendChild(progressBar);
    return progressContainer;
  }

  createActionsContainer(actions, toastId) {
    const container = document.createElement("div");
    container.className = "toast-actions";
    container.style.cssText = `
            display: flex;
            gap: var(--space-2);
            margin-top: var(--space-3);
        `;

    actions.forEach((action) => {
      const btn = document.createElement("button");
      btn.className = `btn btn-${action.type || "ghost"} btn-sm`;
      btn.textContent = action.text;
      btn.style.fontSize = "var(--text-xs)";

      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        if (action.handler) {
          action.handler(toastId);
        }
        if (action.closeOnClick !== false) {
          this.hide(toastId);
        }
      });

      container.appendChild(btn);
    });

    return container;
  }

  setupAutoHide(toastId, duration) {
    const toast = this.toasts.get(toastId);
    if (!toast) return;

    toast.timer = setTimeout(() => {
      this.hide(toastId);
    }, duration);
  }

  setupToastEvents(toastId, config) {
    const toastElement = document.getElementById(toastId);
    if (!toastElement) return;

    // Click handler
    if (config.onClick) {
      toastElement.addEventListener("click", () => {
        config.onClick(toastId);
      });
    }

    // Close button
    const closeBtn = toastElement.querySelector(".toast-close-btn");
    if (closeBtn) {
      closeBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        this.hide(toastId);
      });
    }

    // Pause on hover
    toastElement.addEventListener("mouseenter", () => {
      this.pauseTimer(toastId);
    });

    toastElement.addEventListener("mouseleave", () => {
      this.resumeTimer(toastId, config);
    });
  }

  pauseTimer(toastId) {
    const toast = this.toasts.get(toastId);
    if (toast && toast.timer) {
      clearTimeout(toast.timer);
      toast.timer = null;
    }
  }

  resumeTimer(toastId, config) {
    if (!config.persistent && config.duration > 0) {
      this.setupAutoHide(toastId, config.duration);
    }
  }

  /**
   * Ẩn toast
   */
  hide(toastId) {
    const toast = this.toasts.get(toastId);
    if (!toast) return;

    const element = toast.element;

    // Animation hide
    element.style.transform = "translateX(100%)";
    element.style.opacity = "0";

    setTimeout(() => {
      if (element.parentNode) {
        element.parentNode.removeChild(element);
      }

      // Clear timer
      if (toast.timer) {
        clearTimeout(toast.timer);
      }

      // Callback
      if (toast.config.onClose) {
        toast.config.onClose(toastId);
      }

      this.toasts.delete(toastId);
    }, 300);
  }

  removeOldest() {
    const firstToast = this.toasts.keys().next().value;
    if (firstToast) {
      this.hide(firstToast);
    }
  }

  /**
   * Xóa tất cả toasts
   */
  clear() {
    this.toasts.forEach((_, toastId) => {
      this.hide(toastId);
    });
  }

  /**
   * Success Toast
   */
  success(message, options = {}) {
    return this.show({
      type: "success",
      title: options.title || "Thành công",
      message: message,
      ...options,
    });
  }

  /**
   * Warning Toast
   */
  warning(message, options = {}) {
    return this.show({
      type: "warning",
      title: options.title || "Cảnh báo",
      message: message,
      ...options,
    });
  }

  /**
   * Error Toast
   */
  error(message, options = {}) {
    return this.show({
      type: "error",
      title: options.title || "Lỗi",
      message: message,
      duration: 6000, // Longer duration for errors
      ...options,
    });
  }

  /**
   * Info Toast
   */
  info(message, options = {}) {
    return this.show({
      type: "info",
      title: options.title || "Thông tin",
      message: message,
      ...options,
    });
  }
}

// Export để sử dụng trong SPA framework
window.Toast = Toast;

// Tạo instance global
window.toast = new Toast();
