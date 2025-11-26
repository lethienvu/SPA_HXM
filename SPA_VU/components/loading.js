/**
 * PARADISE HR - LOADING COMPONENTS
 * Modern loading spinners và indicators với glassmorphism effects
 * Supports: Spinner, Progress Bar, Skeleton Loading, Full Screen Loading
 */

class Loading {
  constructor() {
    this.activeLoaders = new Map();
    this.init();
  }

  init() {
    // Thêm CSS animations nếu chưa có
    this.injectStyles();
  }

  injectStyles() {
    if (document.getElementById("loading-styles")) return;

    const style = document.createElement("style");
    style.id = "loading-styles";
    style.textContent = `
            /* Spinner Animations */
            @keyframes spin {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }

            @keyframes spin-reverse {
                from { transform: rotate(360deg); }
                to { transform: rotate(0deg); }
            }

            @keyframes pulse-ring {
                0% { 
                    transform: scale(0.8);
                    opacity: 1;
                }
                100% {
                    transform: scale(1.2);
                    opacity: 0;
                }
            }

            @keyframes dot-bounce {
                0%, 80%, 100% {
                    transform: scale(0);
                    opacity: 0.5;
                }
                40% {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            @keyframes skeleton-wave {
                0% {
                    transform: translateX(-100%);
                }
                100% {
                    transform: translateX(100%);
                }
            }

            @keyframes fade-in-out {
                0%, 100% { opacity: 0.3; }
                50% { opacity: 1; }
            }

            /* Loading Spinner Variants */
            .spinner {
                display: inline-block;
                position: relative;
            }

            .spinner-border {
                width: 24px;
                height: 24px;
                border: 2px solid rgba(113, 193, 29, 0.2);
                border-top: 2px solid var(--brand-primary);
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

            .spinner-border-sm {
                width: 16px;
                height: 16px;
                border-width: 1px;
            }

            .spinner-border-lg {
                width: 32px;
                height: 32px;
                border-width: 3px;
            }

            .spinner-border-xl {
                width: 48px;
                height: 48px;
                border-width: 4px;
            }

            .spinner-dots {
                display: flex;
                gap: 4px;
                align-items: center;
            }

            .spinner-dots .dot {
                width: 8px;
                height: 8px;
                background: var(--brand-primary);
                border-radius: 50%;
                animation: dot-bounce 1.4s infinite ease-in-out both;
            }

            .spinner-dots .dot:nth-child(1) { animation-delay: -0.32s; }
            .spinner-dots .dot:nth-child(2) { animation-delay: -0.16s; }
            .spinner-dots .dot:nth-child(3) { animation-delay: 0s; }

            .spinner-pulse {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                background: var(--brand-primary);
                position: relative;
            }

            .spinner-pulse::before,
            .spinner-pulse::after {
                content: '''';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                border-radius: 50%;
                border: 2px solid var(--brand-primary);
                animation: pulse-ring 2s linear infinite;
            }

            .spinner-pulse::after {
                animation-delay: 1s;
            }

            /* Progress Bar */
            .progress {
                background: var(--neutral-200);
                border-radius: var(--radius-full);
                overflow: hidden;
                height: 8px;
                position: relative;
            }

            .progress-bar {
                height: 100%;
                background: linear-gradient(90deg, var(--brand-primary), var(--brand-primary-light));
                border-radius: var(--radius-full);
                transition: width var(--duration-normal) var(--ease-out);
                position: relative;
                overflow: hidden;
            }

            .progress-bar.animated::after {
                content: '''';
                position: absolute;
                top: 0;
                left: 0;
                bottom: 0;
                right: 0;
                background: linear-gradient(
                    90deg,
                    transparent,
                    rgba(255, 255, 255, 0.4),
                    transparent
                );
                animation: skeleton-wave 2s infinite;
            }

            /* Skeleton Loading */
            .skeleton {
                background: linear-gradient(
                    90deg,
                    var(--neutral-200) 25%,
                    var(--neutral-300) 50%,
                    var(--neutral-200) 75%
                );
                background-size: 200% 100%;
                animation: skeleton-wave 1.5s infinite;
                border-radius: var(--radius-sm);
            }

            .skeleton-text {
                height: 16px;
                margin: 8px 0;
            }

            .skeleton-text.large {
                height: 20px;
            }

            .skeleton-text.small {
                height: 12px;
            }

            .skeleton-avatar {
                width: 48px;
                height: 48px;
                border-radius: 50%;
            }

            .skeleton-button {
                height: 40px;
                width: 120px;
                border-radius: var(--radius-md);
            }

            /* Full Screen Loading */
            .loading-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: var(--bg-overlay);
                backdrop-filter: var(--blur-sm);
                -webkit-backdrop-filter: var(--blur-sm);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: var(--z-modal);
                opacity: 0;
                transition: opacity var(--duration-normal) var(--ease-out);
            }

            .loading-overlay.show {
                opacity: 1;
            }

            .loading-content {
                background: var(--glass-primary);
                backdrop-filter: var(--blur-md);
                -webkit-backdrop-filter: var(--blur-md);
                border: 1px solid var(--glass-border-light);
                border-radius: var(--radius-xl);
                padding: var(--space-8);
                text-align: center;
                box-shadow: var(--shadow-glass-md);
                min-width: 200px;
            }

            .loading-text {
                margin-top: var(--space-4);
                font-size: var(--text-base);
                color: var(--text-secondary);
                font-weight: var(--font-medium);
            }

            /* Button Loading States */
            .btn.loading {
                position: relative;
                color: transparent !important;
                pointer-events: none;
            }

            .btn.loading::after {
                content: '''';
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 16px;
                height: 16px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                border-top: 2px solid currentColor;
                border-radius: 50%;
                animation: spin 1s linear infinite;
                color: white;
            }

            .btn-secondary.loading::after {
                color: var(--text-primary);
                border-color: rgba(0, 0, 0, 0.2);
                border-top-color: var(--text-primary);
            }
        `;
    document.head.appendChild(style);
  }

  /**
   * Tạo spinner element
   */
  createSpinner(type = "border", size = "md", color = "primary") {
    const spinner = document.createElement("div");
    spinner.className = `spinner spinner-${type}`;

    if (type === "border") {
      const element = document.createElement("div");
      element.className = `spinner-border spinner-border-${size}`;

      if (color !== "primary") {
        element.style.borderTopColor = `var(--color-${color})`;
        element.style.borderColor = `rgba(var(--color-${color}), 0.2)`;
      }

      spinner.appendChild(element);
    } else if (type === "dots") {
      spinner.className = "spinner-dots";
      for (let i = 0; i < 3; i++) {
        const dot = document.createElement("div");
        dot.className = "dot";
        if (color !== "primary") {
          dot.style.background = `var(--color-${color})`;
        }
        spinner.appendChild(dot);
      }
    } else if (type === "pulse") {
      const element = document.createElement("div");
      element.className = "spinner-pulse";
      if (color !== "primary") {
        element.style.background = `var(--color-${color})`;
      }
      spinner.appendChild(element);
    }

    return spinner;
  }

  /**
   * Hiển thị loading toàn màn hình
   */
  showFullScreen(options = {}) {
    const defaults = {
      message: "Đang tải...",
      spinner: "border",
      size: "lg",
      color: "primary",
      overlay: true,
    };

    const config = { ...defaults, ...options };
    const loadingId = "loading-" + Date.now();

    // Tạo overlay
    const overlay = document.createElement("div");
    overlay.id = loadingId;
    overlay.className = "loading-overlay";

    // Tạo content
    const content = document.createElement("div");
    content.className = "loading-content";

    // Thêm spinner
    const spinner = this.createSpinner(
      config.spinner,
      config.size,
      config.color
    );
    content.appendChild(spinner);

    // Thêm message
    if (config.message) {
      const message = document.createElement("div");
      message.className = "loading-text";
      message.textContent = config.message;
      content.appendChild(message);
    }

    overlay.appendChild(content);
    document.body.appendChild(overlay);

    // Animation show
    requestAnimationFrame(() => {
      overlay.classList.add("show");
    });

    // Lưu vào map
    this.activeLoaders.set(loadingId, {
      element: overlay,
      type: "fullscreen",
    });

    return loadingId;
  }

  /**
   * Ẩn loading toàn màn hình
   */
  hideFullScreen(loadingId) {
    const loader = this.activeLoaders.get(loadingId);
    if (!loader || loader.type !== "fullscreen") return;

    const overlay = loader.element;
    overlay.classList.remove("show");

    setTimeout(() => {
      if (overlay.parentNode) {
        overlay.parentNode.removeChild(overlay);
      }
      this.activeLoaders.delete(loadingId);
    }, 300);
  }

  /**
   * Hiển thị loading cho button
   */
  showButtonLoading(buttonElement, text = null) {
    if (!buttonElement) return;

    const originalText = buttonElement.textContent;
    buttonElement.classList.add("loading");
    buttonElement.setAttribute("data-original-text", originalText);

    if (text) {
      buttonElement.textContent = text;
    }

    return {
      hide: () => this.hideButtonLoading(buttonElement),
    };
  }

  /**
   * Ẩn loading cho button
   */
  hideButtonLoading(buttonElement) {
    if (!buttonElement) return;

    buttonElement.classList.remove("loading");
    const originalText = buttonElement.getAttribute("data-original-text");
    if (originalText) {
      buttonElement.textContent = originalText;
      buttonElement.removeAttribute("data-original-text");
    }
  }

  /**
   * Tạo progress bar
   */
  createProgressBar(options = {}) {
    const defaults = {
      value: 0,
      max: 100,
      height: 8,
      animated: false,
      color: "primary",
      showLabel: false,
    };

    const config = { ...defaults, ...options };
    const progressId = "progress-" + Date.now();

    const container = document.createElement("div");
    container.id = progressId;
    container.className = "progress-container";

    // Label
    if (config.showLabel) {
      const label = document.createElement("div");
      label.className = "progress-label";
      label.style.cssText = `
                display: flex;
                justify-content: space-between;
                margin-bottom: var(--space-2);
                font-size: var(--text-sm);
                color: var(--text-secondary);
            `;
      label.innerHTML = `
                <span class="progress-text">${config.label || ""}</span>
                <span class="progress-percentage">${Math.round(
                  (config.value / config.max) * 100
                )}%</span>
            `;
      container.appendChild(label);
    }

    // Progress bar
    const progress = document.createElement("div");
    progress.className = "progress";
    progress.style.height = config.height + "px";

    const progressBar = document.createElement("div");
    progressBar.className = `progress-bar ${config.animated ? "animated" : ""}`;
    progressBar.style.width = `${(config.value / config.max) * 100}%`;

    if (config.color !== "primary") {
      progressBar.style.background = `linear-gradient(90deg, var(--color-${config.color}), var(--color-${config.color}-light))`;
    }

    progress.appendChild(progressBar);
    container.appendChild(progress);

    return {
      element: container,
      update: (value) =>
        this.updateProgressBar(progressId, value, config.max, config.showLabel),
      destroy: () => this.destroyProgressBar(progressId),
    };
  }

  updateProgressBar(progressId, value, max = 100, showLabel = false) {
    const container = document.getElementById(progressId);
    if (!container) return;

    const progressBar = container.querySelector(".progress-bar");
    const percentage = Math.round((value / max) * 100);

    progressBar.style.width = `${percentage}%`;

    if (showLabel) {
      const percentageSpan = container.querySelector(".progress-percentage");
      if (percentageSpan) {
        percentageSpan.textContent = `${percentage}%`;
      }
    }
  }

  destroyProgressBar(progressId) {
    const container = document.getElementById(progressId);
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
  }

  /**
   * Tạo skeleton loading
   */
  createSkeleton(type = "text", options = {}) {
    const skeleton = document.createElement("div");

    switch (type) {
      case "text":
        skeleton.className = `skeleton skeleton-text ${options.size || ""}`;
        if (options.width) {
          skeleton.style.width = options.width;
        }
        break;

      case "avatar":
        skeleton.className = "skeleton skeleton-avatar";
        if (options.size) {
          skeleton.style.width = options.size;
          skeleton.style.height = options.size;
        }
        break;

      case "button":
        skeleton.className = "skeleton skeleton-button";
        if (options.width) skeleton.style.width = options.width;
        if (options.height) skeleton.style.height = options.height;
        break;

      case "card":
        skeleton.className = "skeleton";
        skeleton.style.cssText = `
                    height: ${options.height || "200px"};
                    width: ${options.width || "100%"};
                    border-radius: var(--radius-lg);
                `;
        break;
    }

    return skeleton;
  }

  /**
   * Tạo skeleton cho danh sách
   */
  createSkeletonList(container, count = 3, type = "card") {
    const skeletonId = "skeleton-" + Date.now();
    container.setAttribute("data-skeleton-id", skeletonId);

    const originalContent = container.innerHTML;
    container.setAttribute("data-original-content", originalContent);
    container.innerHTML = "";

    for (let i = 0; i < count; i++) {
      const skeletonItem = document.createElement("div");
      skeletonItem.style.cssText = `
                padding: var(--space-4);
                margin-bottom: var(--space-4);
                border-radius: var(--radius-lg);
            `;

      if (type === "list") {
        // Avatar + Text skeleton
        const flex = document.createElement("div");
        flex.style.cssText =
          "display: flex; gap: var(--space-3); align-items: center;";

        flex.appendChild(this.createSkeleton("avatar", { size: "48px" }));

        const textContainer = document.createElement("div");
        textContainer.style.flex = "1";
        textContainer.appendChild(
          this.createSkeleton("text", { size: "large" })
        );
        textContainer.appendChild(
          this.createSkeleton("text", { width: "60%" })
        );

        flex.appendChild(textContainer);
        skeletonItem.appendChild(flex);
      } else {
        // Card skeleton
        skeletonItem.appendChild(
          this.createSkeleton("card", { height: "150px" })
        );
      }

      container.appendChild(skeletonItem);
    }

    return skeletonId;
  }

  /**
   * Xóa skeleton và hiển thị nội dung gốc
   */
  removeSkeleton(container) {
    const originalContent = container.getAttribute("data-original-content");
    if (originalContent !== null) {
      container.innerHTML = originalContent;
      container.removeAttribute("data-original-content");
      container.removeAttribute("data-skeleton-id");
    }
  }

  /**
   * Xóa tất cả loading
   */
  clearAll() {
    this.activeLoaders.forEach((loader, id) => {
      if (loader.type === "fullscreen") {
        this.hideFullScreen(id);
      }
    });
  }
}

// Export để sử dụng trong SPA framework
window.Loading = Loading;

// Tạo instance global
window.loading = new Loading();
