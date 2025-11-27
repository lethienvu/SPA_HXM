// Sidebar Manager Utility - Add to Settings Panel
// This allows users to control sidebar state from settings

export function renderSidebarPreferencesSetting() {
  return `
    <div class="setting-section">
      <h4 class="section-title">📌 Tùy chỉnh Sidebar</h4>
      
      <div class="setting-item">
        <label class="setting-label">Trạng thái mặc định</label>
        <div class="radio-group">
          <label class="radio-option">
            <input type="radio" name="sidebar-default" value="expanded" class="sidebar-default-expanded" />
            <span>📂 Mở (Expanded)</span>
          </label>
          <label class="radio-option">
            <input type="radio" name="sidebar-default" value="collapsed" class="sidebar-default-collapsed" />
            <span>📁 Đóng (Collapsed)</span>
          </label>
        </div>
        <p class="setting-description">Chọn trạng thái sidebar mặc định khi mở ứng dụng</p>
      </div>

      <div class="toggle-item">
        <div class="toggle-info">
          <label class="toggle-label">Ghi nhớ trạng thái</label>
          <p class="toggle-description">Lưu trạng thái sidebar hiện tại khi bạn đóng ứng dụng</p>
        </div>
        <label class="toggle-switch">
          <input type="checkbox" class="sidebar-remember-toggle" checked />
          <span class="toggle-slider"></span>
        </label>
      </div>

      <button class="btn btn-secondary reset-sidebar-btn" style="margin-top: var(--space-3);">
        🔄 Khôi phục mặc định
      </button>

      <style>
        .setting-section {
          padding: var(--space-4);
          background: var(--neutral-50);
          border-radius: var(--radius-md);
          border: 1px solid var(--neutral-100);
          margin-bottom: var(--space-4);
        }

        .section-title {
          font-size: 14px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0 0 var(--space-3) 0;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .setting-description {
          font-size: 12px;
          color: var(--text-secondary);
          margin: var(--space-2) 0 0 0;
        }

        .reset-sidebar-btn {
          font-size: 13px;
        }
      </style>
    </div>
  `;
}

/**
 * Setup sidebar preference listeners (call from Settings component onMount)
 */
export function setupSidebarPreferences() {
  // Expanded option
  const expandedOption = document.querySelector(".sidebar-default-expanded");
  if (expandedOption) {
    const currentState = window.sidebarManager?.getSavedState();
    expandedOption.checked = currentState !== "collapsed";

    expandedOption.addEventListener("change", () => {
      if (expandedOption.checked) {
        window.sidebarManager?.expand();
      }
    });
  }

  // Collapsed option
  const collapsedOption = document.querySelector(".sidebar-default-collapsed");
  if (collapsedOption) {
    const currentState = window.sidebarManager?.getSavedState();
    collapsedOption.checked = currentState === "collapsed";

    collapsedOption.addEventListener("change", () => {
      if (collapsedOption.checked) {
        window.sidebarManager?.collapse();
      }
    });
  }

  // Remember toggle
  const rememberToggle = document.querySelector(".sidebar-remember-toggle");
  if (rememberToggle) {
    const isEnabled =
      localStorage.getItem("paradiseHR_rememberSidebarState") !== "false";
    rememberToggle.checked = isEnabled;

    rememberToggle.addEventListener("change", () => {
      localStorage.setItem(
        "paradiseHR_rememberSidebarState",
        rememberToggle.checked ? "true" : "false"
      );
    });
  }

  // Reset button
  const resetBtn = document.querySelector(".reset-sidebar-btn");
  if (resetBtn) {
    resetBtn.addEventListener("click", () => {
      if (
        confirm("Bạn có chắc chắn muốn khôi phục cài đặt sidebar mặc định?")
      ) {
        window.sidebarManager?.resetState();

        // Update UI
        if (expandedOption) expandedOption.checked = true;
        if (collapsedOption) collapsedOption.checked = false;

        alert("✅ Đã khôi phục cài đặt mặc định");
      }
    });
  }
}

/**
 * Responsive sidebar adjustment for mobile
 * Call this from main application to handle responsive behavior
 */
export function handleResponsiveSidebar() {
  const handleResize = () => {
    const isMobile = window.innerWidth < 768;

    if (isMobile) {
      // Auto-collapse on mobile
      window.sidebarManager?.collapse();
    } else {
      // Auto-expand on desktop
      window.sidebarManager?.expand();
    }
  };

  // Initial check
  handleResize();

  // Listen to resize events
  window.addEventListener("resize", handleResize);

  console.log("✅ Responsive sidebar handler initialized");
}

/**
 * Listen to sidebar state changes
 * Usage:
 * document.addEventListener("sidebarCollapsed", () => { console.log("Collapsed!"); });
 * document.addEventListener("sidebarExpanded", () => { console.log("Expanded!"); });
 */
export function setupSidebarEventListeners(onCollapsed, onExpanded) {
  if (onCollapsed) {
    document.addEventListener("sidebarCollapsed", onCollapsed);
  }

  if (onExpanded) {
    document.addEventListener("sidebarExpanded", onExpanded);
  }

  console.log("✅ Sidebar event listeners set up");

  // Return unsubscribe function
  return {
    unsubscribe: () => {
      if (onCollapsed) {
        document.removeEventListener("sidebarCollapsed", onCollapsed);
      }
      if (onExpanded) {
        document.removeEventListener("sidebarExpanded", onExpanded);
      }
    },
  };
}
