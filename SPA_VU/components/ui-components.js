/**
 * PARADISE HR - CORE COMPONENTS MANAGER
 * Quản lý tất cả UI components trong SPA framework
 * Tích hợp với router và component lifecycle
 */

class UIComponents {
  constructor() {
    this.components = {
      modal: null,
      toast: null,
      loading: null,
      alert: null,
    };

    this.initialized = false;
    this.loadQueue = [];
  }

  /**
   * Khởi tạo tất cả components
   */
  async init() {
    if (this.initialized) return;

    try {
      // Load tất cả component scripts
      await this.loadComponents();

      // Khởi tạo instances
      this.initializeInstances();

      // Setup global shortcuts
      this.setupGlobalShortcuts();

      // Setup automatic integrations
      this.setupIntegrations();

      this.initialized = true;
      console.log("🎉 Paradise HR UI Components initialized successfully");

      // Process queue
      this.processQueue();
    } catch (error) {
      console.error("❌ Failed to initialize UI Components:", error);
    }
  }

  /**
   * Load component scripts
   */
  async loadComponents() {
    // Check if components are already loaded via script tags
    if (
      typeof Modal !== "undefined" &&
      typeof Toast !== "undefined" &&
      typeof Loading !== "undefined" &&
      typeof Alert !== "undefined"
    ) {
      console.log("✅ All component classes already loaded");
      return;
    }

    const components = [
      "components/modal.js",
      "components/toast.js",
      "components/loading.js",
      "components/alert.js",
    ];

    const loadPromises = components.map((src) => this.loadScript(src));
    await Promise.all(loadPromises);
  }

  /**
   * Load script dynamically
   */
  loadScript(src) {
    return new Promise((resolve, reject) => {
      // Check if already loaded
      if (document.querySelector(`script[src="${src}"]`)) {
        resolve();
        return;
      }

      const script = document.createElement("script");
      script.src = src;
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  /**
   * Initialize component instances
   */
  initializeInstances() {
    // Check if classes are available
    if (typeof Modal !== "undefined") {
      this.components.modal = window.modal || new Modal();
    }

    if (typeof Toast !== "undefined") {
      this.components.toast = window.toast || new Toast();
    }

    if (typeof Loading !== "undefined") {
      this.components.loading = window.loading || new Loading();
    }

    if (typeof Alert !== "undefined") {
      this.components.alert = window.alert || new Alert();
    }
  }

  /**
   * Setup global shortcuts
   */
  setupGlobalShortcuts() {
    // Global UI object
    window.UI = {
      // Modal methods
      modal: {
        show: (options) => this.modal(options),
        success: (options) => this.modalSuccess(options),
        warning: (options) => this.modalWarning(options),
        error: (options) => this.modalError(options),
        info: (options) => this.modalInfo(options),
        confirm: (options) => this.confirm(options),
        close: (id) => this.components.modal?.close(id),
        closeAll: () => this.components.modal?.closeAll(),
      },

      // Toast methods
      toast: {
        show: (message, options) => this.toast(message, options),
        success: (message, options) => this.toastSuccess(message, options),
        warning: (message, options) => this.toastWarning(message, options),
        error: (message, options) => this.toastError(message, options),
        info: (message, options) => this.toastInfo(message, options),
        clear: () => this.components.toast?.clear(),
      },

      // Loading methods
      loading: {
        show: (options) => this.showLoading(options),
        hide: (id) => this.hideLoading(id),
        button: (element, text) => this.buttonLoading(element, text),
        progress: (options) => this.progressBar(options),
        clearAll: () => this.components.loading?.clearAll(),
        // Direct access to loading component methods
        spinner: (type, size, color) =>
          this.components.loading?.createSpinner(type, size, color),
        fullScreen: (options) =>
          this.components.loading?.showFullScreen(options),
        hideFullScreen: (id) => this.components.loading?.hideFullScreen(id),
        skeleton: (type, options) =>
          this.components.loading?.createSkeleton(type, options),
        skeletonList: (container, count, type) =>
          this.components.loading?.createSkeletonList(container, count, type),
        removeSkeleton: (container) =>
          this.components.loading?.removeSkeleton(container),
        updateProgress: (id, value, max, showLabel) =>
          this.components.loading?.updateProgressBar(id, value, max, showLabel),
        destroyProgress: (id) =>
          this.components.loading?.destroyProgressBar(id),
      },

      // Alert methods
      alert: {
        show: (message, options) => this.alert(message, options),
        success: (message, options) => this.alertSuccess(message, options),
        warning: (message, options) => this.alertWarning(message, options),
        error: (message, options) => this.alertError(message, options),
        info: (message, options) => this.alertInfo(message, options),
        banner: (message, options) => this.banner(message, options),
        dismiss: (id) => this.components.alert?.dismiss(id),
        dismissAll: () => this.components.alert?.dismissAll(),
      },
    };

    // Backward compatibility
    window.showModal = (options) => this.modal(options);
    window.showToast = (message, type) => this.toast(message, { type });
    window.showLoading = (options) => this.showLoading(options);
    window.hideLoading = (id) => this.hideLoading(id);
  }

  /**
   * Setup automatic integrations
   */
  setupIntegrations() {
    // Auto-submit form with loading
    this.setupFormIntegration();

    // Auto-confirm dangerous actions
    this.setupConfirmIntegration();

    // Auto-handle AJAX errors
    this.setupAjaxIntegration();

    // Auto-loading for navigation
    this.setupNavigationIntegration();
  }

  setupFormIntegration() {
    document.addEventListener("submit", (e) => {
      const form = e.target;
      if (!form.matches("form[data-loading]")) return;

      const submitBtn = form.querySelector(
        'button[type="submit"], input[type="submit"]'
      );
      if (submitBtn) {
        const loadingText =
          form.getAttribute("data-loading-text") || "Đang xử lý...";
        this.buttonLoading(submitBtn, loadingText);

        // Auto-hide after 10 seconds (fallback)
        setTimeout(() => {
          this.components.loading?.hideButtonLoading(submitBtn);
        }, 10000);
      }
    });
  }

  setupConfirmIntegration() {
    document.addEventListener("click", (e) => {
      const element = e.target.closest("[data-confirm]");
      if (!element) return;

      e.preventDefault();

      const message = element.getAttribute("data-confirm");
      const title = element.getAttribute("data-confirm-title") || "Xác nhận";

      this.confirm({
        title: title,
        content: message,
        onConfirm: () => {
          // Execute original action
          if (element.tagName === "A") {
            window.location.href = element.href;
          } else if (element.tagName === "BUTTON" && element.form) {
            element.form.submit();
          } else if (element.onclick) {
            element.onclick();
          }
        },
      });
    });
  }

  setupAjaxIntegration() {
    // Override fetch to show loading and handle errors
    const originalFetch = window.fetch;

    window.fetch = async (...args) => {
      const loadingId = this.showLoading({ message: "Đang tải..." });

      try {
        const response = await originalFetch(...args);

        if (!response.ok) {
          this.toastError(`Lỗi ${response.status}: ${response.statusText}`);
        }

        return response;
      } catch (error) {
        this.toastError("Lỗi kết nối mạng");
        throw error;
      } finally {
        this.hideLoading(loadingId);
      }
    };
  }

  setupNavigationIntegration() {
    // Show loading during route changes
    if (window.router) {
      const originalNavigate = window.router.navigate;

      window.router.navigate = function (...args) {
        const loadingId = window.uiComponents.showLoading({
          message: "Đang chuyển trang...",
        });

        const result = originalNavigate.apply(this, args);

        // Hide loading after navigation
        setTimeout(() => {
          window.uiComponents.hideLoading(loadingId);
        }, 500);

        return result;
      };
    }
  }

  // ==========================================================================
  // PUBLIC API METHODS
  // ==========================================================================

  /**
   * Show modal
   */
  modal(options = {}) {
    if (!this.components.modal) {
      this.queueAction("modal", arguments);
      return null;
    }
    return this.components.modal.create(options);
  }

  modalSuccess(options = {}) {
    return this.components.modal?.success(options);
  }

  modalWarning(options = {}) {
    return this.components.modal?.warning(options);
  }

  modalError(options = {}) {
    return this.components.modal?.error(options);
  }

  modalInfo(options = {}) {
    return this.components.modal?.info(options);
  }

  confirm(options = {}) {
    return this.components.modal?.confirm(options);
  }

  /**
   * Show toast
   */
  toast(message, options = {}) {
    if (!this.components.toast) {
      this.queueAction("toast", arguments);
      return null;
    }
    return this.components.toast.show({ message, ...options });
  }

  toastSuccess(message, options = {}) {
    return this.components.toast?.success(message, options);
  }

  toastWarning(message, options = {}) {
    return this.components.toast?.warning(message, options);
  }

  toastError(message, options = {}) {
    return this.components.toast?.error(message, options);
  }

  toastInfo(message, options = {}) {
    return this.components.toast?.info(message, options);
  }

  /**
   * Show loading
   */
  showLoading(options = {}) {
    if (!this.components.loading) {
      this.queueAction("showLoading", arguments);
      return null;
    }
    return this.components.loading.showFullScreen(options);
  }

  hideLoading(loadingId) {
    this.components.loading?.hideFullScreen(loadingId);
  }

  buttonLoading(element, text) {
    return this.components.loading?.showButtonLoading(element, text);
  }

  progressBar(options = {}) {
    return this.components.loading?.createProgressBar(options);
  }

  /**
   * Show alert
   */
  alert(message, options = {}) {
    if (!this.components.alert) {
      this.queueAction("alert", arguments);
      return null;
    }
    return this.components.alert.create({ message, ...options });
  }

  alertSuccess(message, options = {}) {
    return this.components.alert?.success(message, options);
  }

  alertWarning(message, options = {}) {
    return this.components.alert?.warning(message, options);
  }

  alertError(message, options = {}) {
    return this.components.alert?.error(message, options);
  }

  alertInfo(message, options = {}) {
    return this.components.alert?.info(message, options);
  }

  banner(message, options = {}) {
    return this.components.alert?.banner(message, options);
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /**
   * Queue actions until components are loaded
   */
  queueAction(method, args) {
    this.loadQueue.push({ method, args });
  }

  /**
   * Process queued actions
   */
  processQueue() {
    while (this.loadQueue.length > 0) {
      const { method, args } = this.loadQueue.shift();
      if (typeof this[method] === "function") {
        this[method](...args);
      }
    }
  }

  /**
   * Check if components are ready
   */
  isReady() {
    return this.initialized;
  }

  /**
   * Get component instance
   */
  getComponent(name) {
    return this.components[name];
  }

  /**
   * Cleanup all components
   */
  cleanup() {
    this.components.modal?.closeAll();
    this.components.toast?.clear();
    this.components.loading?.clearAll();
    this.components.alert?.dismissAll();
  }

  // ==========================================================================
  // CONVENIENCE METHODS
  // ==========================================================================

  /**
   * Quick success feedback
   */
  success(message, persistent = false) {
    if (persistent) {
      this.modalSuccess({ content: message });
    } else {
      this.toastSuccess(message);
    }
  }

  /**
   * Quick error feedback
   */
  error(message, persistent = true) {
    if (persistent) {
      this.modalError({ content: message });
    } else {
      this.toastError(message);
    }
  }

  /**
   * Quick warning feedback
   */
  warning(message, persistent = false) {
    if (persistent) {
      this.modalWarning({ content: message });
    } else {
      this.toastWarning(message);
    }
  }

  /**
   * Quick info feedback
   */
  info(message, persistent = false) {
    if (persistent) {
      this.modalInfo({ content: message });
    } else {
      this.toastInfo(message);
    }
  }

  /**
   * Ask for confirmation
   */
  askConfirm(message, onConfirm, onCancel = null) {
    return this.confirm({
      content: message,
      onConfirm: onConfirm,
      onCancel: onCancel,
    });
  }

  /**
   * Show loading with promise
   */
  withLoading(promise, message = "Đang xử lý...") {
    const loadingId = this.showLoading({ message });

    return promise.finally(() => {
      this.hideLoading(loadingId);
    });
  }
}

// Initialize và export
window.UIComponents = UIComponents;
window.uiComponents = new UIComponents();

// Auto-initialize khi DOM ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    window.uiComponents.init();
  });
} else {
  window.uiComponents.init();
}
