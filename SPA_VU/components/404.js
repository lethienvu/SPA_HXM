// 404 - Worker Not Found Component
import { Component } from "../app.js";

export default class NotFound extends Component {
  render() {
    return `
      <div class="not-found-container">
        <!-- Animated Background -->
        <div class="not-found-background">
          <div class="floating-shape shape-1"></div>
          <div class="floating-shape shape-2"></div>
          <div class="floating-shape shape-3"></div>
        </div>

        <!-- Main Content -->
        <div class="not-found-content">
          <!-- Animated 404 Number -->
          <div class="not-found-number-wrapper">
            <div class="not-found-number">
              <span class="digit digit-4 digit-1">4</span>
              <span class="digit digit-0">0</span>
              <span class="digit digit-4 digit-2">4</span>
            </div>
            <div class="not-found-decoration">
              <svg class="decoration-icon" viewBox="0 0 24 24" width="80" height="80">
                <circle class="tone-1" cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>
                <path class="tone-2" d="M12 7v5l3 3" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </div>
          </div>

          <!-- Heading -->
          <h1 class="not-found-title">Worker Not Found</h1>
          <p class="not-found-subtitle">Nhân viên bạn tìm kiếm không tồn tại hoặc đã bị xóa khỏi hệ thống.</p>

          <!-- Error Details -->
          <div class="not-found-details">
            <div class="detail-item">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"></circle>
                <path d="m21 21-4.35-4.35"></path>
              </svg>
              <span>Kiểm tra ID nhân viên của bạn</span>
            </div>
            <div class="detail-item">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"></path>
                <path d="M12 6v6l4 2"></path>
              </svg>
              <span>Dữ liệu có thể bị xóa hoặc lỗi tạm thời</span>
            </div>
            <div class="detail-item">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3.05h16.94a2 2 0 0 0 1.71-3.05L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                <line x1="12" y1="9" x2="12" y2="13"></line>
                <line x1="12" y1="17" x2="12.01" y2="17"></line>
              </svg>
              <span>Liên hệ quản trị viên nếu cần hỗ trợ</span>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="not-found-actions">
            <a href="/" data-link class="btn btn-primary btn-lg">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="m12 19-7-7 7-7"></path>
                <path d="M19 12H5"></path>
              </svg>
              Quay lại Dashboard
            </a>
            <a href="/employees" data-link class="btn btn-secondary btn-lg">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                <circle cx="9" cy="7" r="4"></circle>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
              </svg>
              Danh sách nhân viên
            </a>
          </div>

          <!-- Search Suggestion -->
          <div class="not-found-search">
            <input type="text" class="search-input" placeholder="Tìm kiếm ID nhân viên..." id="notFoundSearch">
            <button class="search-button" onclick="console.log('Search:', document.getElementById('notFoundSearch').value)">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"></circle>
                <path d="m21 21-4.35-4.35"></path>
              </svg>
            </button>
          </div>
        </div>

        <!-- Help Card -->
        <div class="not-found-help">
          <h3 class="help-title">Cần giúp đỡ?</h3>
          <p class="help-text">Nếu bạn gặp vấn đề, vui lòng liên hệ với bộ phận quản trị hoặc hỗ trợ kỹ thuật.</p>
          <a href="#" class="help-link">Liên hệ Hỗ trợ →</a>
        </div>
      </div>
    `;
  }
}
