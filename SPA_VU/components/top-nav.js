// Top Navigation - Minimal, Subtle Style, Title Bold, No Icon, No Shadow
export default function renderTopNav({ title = "Dashboard", breadcrumb = [] }) {
  const breadcrumbHTML = breadcrumb
    .map((item, idx) => {
      if (item.link) {
        return `<a href="${
          item.link
        }" class="breadcrumb-link"><span class="breadcrumb-icon" style="display:inline-block;vertical-align:middle;">${
          item.icon || ""
        }</span> ${item.label}</a>`;
      }
      return `<span class="breadcrumb-current"><span class="breadcrumb-icon" style="display:inline-block;vertical-align:middle;">${
        item.icon || ""
      }</span> ${item.label}</span>`;
    })
    .join('<span class="breadcrumb-sep">›</span>');

  return `
    <nav class="topnav-minimal glass-effect">
      <div class="topnav-row">
        <div class="topnav-title">
          <span class="topnav-title-text">${title}</span>
        </div>
        <nav class="topnav-breadcrumb-minimal">
          ${breadcrumbHTML}
        </nav>
      </div>
    </nav>
    <style>
      .topnav-minimal {
        padding: 0.5rem 1rem;
        padding-left: 0;
        border-radius: 12px;
        min-height: 36px;
        margin-bottom: 0.8rem;
        margin-top: 0.5rem;
        position: relative;
        z-index: 10;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: none;
      }
      .topnav-row {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 0.8rem;
      }
      .topnav-title {
        display: flex;
        align-items: center;
        gap: 0.3rem;
      }
      .topnav-title-text {
        font-size: 1.4rem;
        font-weight: 800;
        color: var(--brand-secondary-dark);
        letter-spacing: 0.01em;
        text-transform: uppercase;
      }
      .topnav-breadcrumb-minimal {
        display: flex;
        align-items: center;
        gap: 0.3rem;
        font-size: 0.92rem;
        background: none;
        border-radius: 8px;
        padding: 0;
        box-shadow: none;
      }
      .breadcrumb-link {
        color: #E67514;
        text-decoration: none;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.1rem;
        font-weight: 500;
        border-radius: 6px;
        padding: 0.05rem 0.2rem;
        transition: background 0.2s, color 0.2s;
      }
      .breadcrumb-link:hover {
        background: rgba(115,196,29,0.06);
        color: var(--brand-primary-dark);
      }
      .breadcrumb-icon {
        margin-right: 0.05rem;
        border-radius: 0;
        background: none;
        box-shadow: none;
        padding: 0;
        display: inline-block;
        vertical-align: middle;
        opacity: 1;
      }
    .breadcrumb-icon svg {
        width: 0.8em;
        height: 0.8em;
        fill: #555;
    }


      .breadcrumb-sep {
        color: var(--text-secondary);
        font-size: 1rem;
        margin: 0 0.05rem;
        opacity: 0.5;
      }
      .breadcrumb-current {
        color: #E67514;
        font-weight: 500;
        background: none;
        border-radius: 6px;
        padding: 0.05rem 0.2rem;
        letter-spacing: 0.01em;
        opacity: 0.8;
      }
      @media (max-width: 768px) {
        .topnav-minimal {
          padding: 0.15rem 0.3rem;
          min-height: 28px;
        }
        .topnav-title-text {
          font-size: 1rem;
        }
        .topnav-breadcrumb-minimal {
          font-size: 0.8rem;
        }
      }
    </style>
  `;
}
