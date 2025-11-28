// About component
// Component is global

window.About = class About extends Component {
  render() {
    return `
      <div>
        <h2>About Mini SPA</h2>
        <p>Đây là demo framework SPA nhỏ, dùng để minh hoạ các khái niệm:</p>
        <ul>
          <li>Client-side routing (history & hash fallback)</li>
          <li>Component lifecycle: render, onMount, onUnmount</li>
          <li>Lazy loading components bằng dynamic import()</li>
          <li>Simple param routing (e.g. /users/:id)</li>
        </ul>
        <p>Source: built with HTML, Bootstrap và vanilla JS.</p>
      </div>
    `;
  }
}
