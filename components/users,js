// Users component (fetch demo)
import { Component } from '../app.js';

export default class Users extends Component {
  constructor(props) {
    super(props);
    this.state = { users: [], loading: false, error: null };
  }

  async fetchUsers() {
    this.state.loading = true;
    this.update();
    try {
      const res = await fetch('https://jsonplaceholder.typicode.com/users');
      this.state.users = await res.json();
    } catch (e) {
      this.state.error = e.message;
    } finally {
      this.state.loading = false;
      this.update();
    }
  }

  onMount() {
    // if route has params.id show detail, else fetch list
    const id = this.props.params && this.props.params.id;
    if (!id) this.fetchUsers();
  }

  renderUserList() {
    if (this.state.loading) return `<div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div>`;
    if (this.state.error) return `<div class="alert alert-danger">${this.state.error}</div>`;
    return `
      <div class="row row-cols-1 row-cols-md-2 g-3">
        ${this.state.users.map(u => `
          <div class="col">
            <div class="card h-100">
              <div class="card-body">
                <h5 class="card-title">${u.name}</h5>
                <p class="card-text">${u.email}</p>
                <a href="/users/${u.id}" class="btn btn-sm btn-outline-primary" data-link>View</a>
              </div>
            </div>
          </div>
        `).join('')}
      </div>
    `;
  }

  renderDetail(id) {
    const user = this.state.users.find(u => String(u.id) === String(id));
    if (!user) {
      return `<p>User #${id} - detail will be fetched from server in a real app.</p><p><a class="btn btn-secondary" href="/users" data-link>Back</a></p>`;
    }
    return `
      <div class="card">
        <div class="card-body">
          <h4>${user.name} <small class="text-muted">#${user.id}</small></h4>
          <p><strong>Email:</strong> ${user.email}</p>
          <p><strong>Phone:</strong> ${user.phone}</p>
          <p><strong>Company:</strong> ${user.company?.name || '-'}</p>
          <a class="btn btn-secondary" href="/users" data-link>Back</a>
        </div>
      </div>
    `;
  }

  update() {
    if (this.el) this.el.innerHTML = this.render();
  }

  render() {
    const id = this.props.params && this.props.params.id;
    return `
      <div>
        <h2>Users</h2>
        ${id ? this.renderDetail(id) : this.renderUserList()}
      </div>
    `;
  }
}