/**
 * PARADISE HR - ALERT & BANNER COMPONENTS
 * Modern alert banners với glassmorphism effects
 * Supports: Info, Success, Warning, Error alerts & system banners
 */

class Alert {
  constructor() {
    this.activeAlerts = new Map();
    this.init();
  }

  init() {
    this.injectStyles();
  }

  injectStyles() {
    if (document.getElementById("alert-styles")) return;

    const style = document.createElement("style");
    style.id = "alert-styles";
    style.textContent = `
            /* Alert Base Styles */
            .alert {
                position: relative;
                padding: var(--space-4);
                border-radius: var(--radius-lg);
                border: 1px solid transparent;
                margin-bottom: var(--space-4);
                display: flex;
                align-items: flex-start;
                gap: var(--space-3);
                transition: all var(--duration-normal) var(--ease-out);
                backdrop-filter: var(--blur-sm);
                -webkit-backdrop-filter: var(--blur-sm);
            }

            .alert.dismissible {
                padding-right: var(--space-12);
            }

            /* Alert Types */
            .alert-success {
                background: var(--color-success-bg);
                border-color: var(--color-success);
                color: var(--color-success-dark);
            }

            .alert-warning {
                background: var(--color-warning-bg);
                border-color: var(--color-warning);
                color: var(--color-warning-dark);
            }

            .alert-error {
                background: var(--color-error-bg);
                border-color: var(--color-error);
                color: var(--color-error-dark);
            }

            .alert-info {
                background: var(--color-info-bg);
                border-color: var(--color-info);
                color: var(--color-info-dark);
            }

            /* Glass Alert Variants */
            .alert-glass {
                background: var(--glass-primary);
                backdrop-filter: var(--blur-md);
                -webkit-backdrop-filter: var(--blur-md);
                border: 1px solid var(--glass-border-light);
                color: var(--text-primary);
            }

            .alert-glass.alert-success {
                border-left: 4px solid var(--color-success);
            }

            .alert-glass.alert-warning {
                border-left: 4px solid var(--color-warning);
            }

            .alert-glass.alert-error {
                border-left: 4px solid var(--color-error);
            }

            .alert-glass.alert-info {
                border-left: 4px solid var(--color-info);
            }

            /* Alert Icon */
            .alert-icon {
                flex-shrink: 0;
                width: 24px;
                height: 24px;
                border-radius: var(--radius-full);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: var(--text-base);
                color: white;
                margin-top: 2px;
            }

            .alert-success .alert-icon {
                background: var(--color-success);
            }

            .alert-warning .alert-icon {
                background: var(--color-warning);
            }

            .alert-error .alert-icon {
                background: var(--color-error);
            }

            .alert-info .alert-icon {
                background: var(--color-info);
            }

            /* Alert Content */
            .alert-content {
                flex: 1;
                min-width: 0;
            }

            .alert-title {
                font-size: var(--text-base);
                font-weight: var(--font-semibold);
                margin-bottom: var(--space-1);
                line-height: var(--leading-tight);
            }

            .alert-message {
                font-size: var(--text-sm);
                line-height: var(--leading-relaxed);
                opacity: 0.9;
            }

            .alert-actions {
                margin-top: var(--space-3);
                display: flex;
                gap: var(--space-2);
            }

            /* Close Button */
            .alert-close {
                position: absolute;
                top: var(--space-3);
                right: var(--space-3);
                background: none;
                border: none;
                color: currentColor;
                opacity: 0.6;
                cursor: pointer;
                padding: var(--space-1);
                border-radius: var(--radius-sm);
                transition: all var(--duration-fast) var(--ease-out);
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                font-size: var(--text-sm);
            }

            .alert-close:hover {
                opacity: 1;
                background: rgba(0, 0, 0, 0.1);
            }

            /* Banner Styles */
            .banner {
                position: sticky;
                top: 0;
                z-index: var(--z-sticky);
                padding: var(--space-3) var(--space-4);
                text-align: center;
                font-size: var(--text-sm);
                font-weight: var(--font-medium);
                border: none;
                border-radius: 0;
                margin: 0;
                backdrop-filter: var(--blur-md);
                -webkit-backdrop-filter: var(--blur-md);
            }

            .banner.banner-top {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                transform: translateY(-100%);
                transition: transform var(--duration-normal) var(--ease-out);
            }

            .banner.banner-top.show {
                transform: translateY(0);
            }

            .banner.banner-bottom {
                position: fixed;
                bottom: 0;
                left: 0;
                right: 0;
                transform: translateY(100%);
                transition: transform var(--duration-normal) var(--ease-out);
            }

            .banner.banner-bottom.show {
                transform: translateY(0);
            }

            /* Compact Alert */
            .alert-compact {
                padding: var(--space-2) var(--space-3);
                font-size: var(--text-sm);
            }

            .alert-compact .alert-icon {
                width: 20px;
                height: 20px;
                font-size: var(--text-sm);
            }

            .alert-compact .alert-title {
                font-size: var(--text-sm);
                margin-bottom: var(--space-1);
            }

            .alert-compact .alert-message {
                font-size: var(--text-xs);
            }

            /* Alert Animations */
            @keyframes alert-slide-down {
                from {
                    transform: translateY(-20px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            @keyframes alert-slide-up {
                from {
                    transform: translateY(20px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            @keyframes alert-fade-out {
                from {
                    opacity: 1;
                    transform: scale(1);
                }
                to {
                    opacity: 0;
                    transform: scale(0.95);
                }
            }

            .alert.animate-in {
                animation: alert-slide-down var(--duration-normal) var(--ease-out);
            }

            .alert.animate-out {
                animation: alert-fade-out var(--duration-normal) var(--ease-out);
            }
        `;
    document.head.appendChild(style);
  }

  /**
   * Tạo alert element
   */
  create(options = {}) {
    const defaults = {
      type: "info", // success, warning, error, info
      title: "",
      message: "",
      dismissible: true,
      showIcon: true,
      glass: false,
      compact: false,
      duration: 0, // 0 = no auto dismiss
      position: "static", // static, top, bottom
      container: null,
      customClass: "",
      actions: [],
      onShow: null,
      onDismiss: null,
    };

    const config = { ...defaults, ...options };
    const alertId =
      "alert-" + Date.now() + "-" + Math.random().toString(36).substr(2, 9);

    // Tạo alert element
    const alertElement = this.createAlertElement(alertId, config);

    // Thêm vào container
    const container = config.container || document.body;

    if (config.position === "top" || config.position === "bottom") {
      this.createBannerAlert(alertElement, config);
    } else {
      container.appendChild(alertElement);
    }

    // Animation
    if (config.position === "static") {
      alertElement.classList.add("animate-in");
    }

    // Setup events
    this.setupAlertEvents(alertId, config);

    // Auto dismiss
    if (config.duration > 0) {
      setTimeout(() => {
        this.dismiss(alertId);
      }, config.duration);
    }

    // Callback
    if (config.onShow) {
      setTimeout(() => config.onShow(alertId), 100);
    }

    // Lưu vào map
    this.activeAlerts.set(alertId, {
      element: alertElement,
      config: config,
    });

    return alertId;
  }

  createAlertElement(alertId, config) {
    const alert = document.createElement("div");
    alert.id = alertId;
    alert.className = this.buildAlertClasses(config);

    // Icon
    if (config.showIcon) {
      const icon = this.createAlertIcon(config.type);
      alert.appendChild(icon);
    }

    // Content
    const content = this.createAlertContent(config);
    alert.appendChild(content);

    // Close button
    if (config.dismissible) {
      const closeBtn = this.createCloseButton();
      alert.appendChild(closeBtn);
    }

    return alert;
  }

  buildAlertClasses(config) {
    let classes = ["alert", `alert-${config.type}`];

    if (config.glass) classes.push("alert-glass");
    if (config.compact) classes.push("alert-compact");
    if (config.dismissible) classes.push("dismissible");
    if (config.position === "top" || config.position === "bottom") {
      classes.push("banner", `banner-${config.position}`);
    }
    if (config.customClass) classes.push(config.customClass);

    return classes.join(" ");
  }

  createAlertIcon(type) {
    const iconContainer = document.createElement("div");
    iconContainer.className = "alert-icon";

    const iconMap = {
      success: "bi bi-check-circle-fill",
      warning: "bi bi-exclamation-triangle-fill",
      error: "bi bi-x-circle-fill",
      info: "bi bi-info-circle-fill",
    };

    const icon = document.createElement("i");
    icon.className = iconMap[type] || iconMap.info;
    iconContainer.appendChild(icon);

    return iconContainer;
  }

  createAlertContent(config) {
    const content = document.createElement("div");
    content.className = "alert-content";

    // Title
    if (config.title) {
      const title = document.createElement("div");
      title.className = "alert-title";
      title.textContent = config.title;
      content.appendChild(title);
    }

    // Message
    if (config.message) {
      const message = document.createElement("div");
      message.className = "alert-message";

      if (typeof config.message === "string") {
        message.innerHTML = config.message;
      } else {
        message.appendChild(config.message);
      }

      content.appendChild(message);
    }

    // Actions
    if (config.actions && config.actions.length > 0) {
      const actionsContainer = this.createActionsContainer(config.actions);
      content.appendChild(actionsContainer);
    }

    return content;
  }

  createActionsContainer(actions) {
    const container = document.createElement("div");
    container.className = "alert-actions";

    actions.forEach((action) => {
      const btn = document.createElement("button");
      btn.className = `btn btn-${action.type || "ghost"} btn-sm`;
      btn.textContent = action.text;

      if (action.handler) {
        btn.addEventListener("click", action.handler);
      }

      container.appendChild(btn);
    });

    return container;
  }

  createCloseButton() {
    const closeBtn = document.createElement("button");
    closeBtn.className = "alert-close";
    closeBtn.innerHTML = ''<i class="bi bi-x"></i>'';
    closeBtn.setAttribute("aria-label", "Đóng thông báo");

    return closeBtn;
  }

  createBannerAlert(alertElement, config) {
    document.body.appendChild(alertElement);

    // Show animation
    requestAnimationFrame(() => {
      alertElement.classList.add("show");
    });

    // Adjust body padding
    if (config.position === "top") {
      document.body.style.paddingTop = alertElement.offsetHeight + "px";
    } else if (config.position === "bottom") {
      document.body.style.paddingBottom = alertElement.offsetHeight + "px";
    }
  }

  setupAlertEvents(alertId, config) {
    const alertElement = document.getElementById(alertId);
    if (!alertElement) return;

    // Close button
    const closeBtn = alertElement.querySelector(".alert-close");
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        this.dismiss(alertId);
      });
    }

    // Click to dismiss (for banners)
    if (config.position === "top" || config.position === "bottom") {
      alertElement.addEventListener("click", () => {
        this.dismiss(alertId);
      });
    }
  }

  /**
   * Dismiss alert
   */
  dismiss(alertId) {
    const alert = this.activeAlerts.get(alertId);
    if (!alert) return;

    const element = alert.element;
    const config = alert.config;

    // Animation
    if (config.position === "top" || config.position === "bottom") {
      element.classList.remove("show");

      // Reset body padding
      setTimeout(() => {
        if (config.position === "top") {
          document.body.style.paddingTop = "";
        } else {
          document.body.style.paddingBottom = "";
        }
      }, 300);
    } else {
      element.classList.add("animate-out");
    }

    // Remove element
    setTimeout(() => {
      if (element.parentNode) {
        element.parentNode.removeChild(element);
      }

      // Callback
      if (config.onDismiss) {
        config.onDismiss(alertId);
      }

      this.activeAlerts.delete(alertId);
    }, 300);
  }

  /**
   * Success Alert
   */
  success(message, options = {}) {
    return this.create({
      type: "success",
      title: options.title || "Thành công",
      message: message,
      ...options,
    });
  }

  /**
   * Warning Alert
   */
  warning(message, options = {}) {
    return this.create({
      type: "warning",
      title: options.title || "Cảnh báo",
      message: message,
      ...options,
    });
  }

  /**
   * Error Alert
   */
  error(message, options = {}) {
    return this.create({
      type: "error",
      title: options.title || "Lỗi",
      message: message,
      duration: 0, // Errors should be persistent by default
      ...options,
    });
  }

  /**
   * Info Alert
   */
  info(message, options = {}) {
    return this.create({
      type: "info",
      title: options.title || "Thông tin",
      message: message,
      ...options,
    });
  }

  /**
   * System Banner
   */
  banner(message, options = {}) {
    return this.create({
      type: options.type || "info",
      message: message,
      position: options.position || "top",
      dismissible: options.dismissible !== false,
      showIcon: false,
      glass: true,
      ...options,
    });
  }

  /**
   * Maintenance Banner
   */
  maintenance(message, options = {}) {
    return this.banner(message, {
      type: "warning",
      title: "Bảo trì hệ thống",
      position: "top",
      dismissible: false,
      ...options,
    });
  }

  /**
   * Dismiss all alerts
   */
  dismissAll() {
    this.activeAlerts.forEach((_, alertId) => {
      this.dismiss(alertId);
    });
  }

  /**
   * Dismiss alerts by type
   */
  dismissByType(type) {
    this.activeAlerts.forEach((alert, alertId) => {
      if (alert.config.type === type) {
        this.dismiss(alertId);
      }
    });
  }
}

// Export để sử dụng trong SPA framework
window.Alert = Alert;

// Tạo instance global
window.alert = new Alert();
