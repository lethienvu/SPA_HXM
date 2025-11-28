// Performance Evaluation Component - Paradise HR SPA


class PerformanceManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      evaluations: [
        {
          id: 1,
          employee: "Nguyễn Văn A",
          evaluator: "Lê Thị Bích",
          period: "Q4 2024",
          rating: 4.5,
          maxRating: 5,
          categories: {
            productivity: 4,
            quality: 5,
            teamwork: 4,
            communication: 4.5,
            punctuality: 5,
          },
          feedback:
            "Nhân viên có hiệu suất xuất sắc, chủ động trong công việc.",
          date: "2024-12-15",
        },
        {
          id: 2,
          employee: "Trần Thị B",
          evaluator: "Trần Thị Thu Trang",
          period: "Q4 2024",
          rating: 3.8,
          maxRating: 5,
          categories: {
            productivity: 3.5,
            quality: 4,
            teamwork: 4,
            communication: 3.5,
            punctuality: 4,
          },
          feedback: "Hiệu suất tốt, cần cải thiện kỹ năng giao tiếp.",
          date: "2024-12-14",
        },
        {
          id: 3,
          employee: "Lê Quốc C",
          evaluator: "Phạm Quang Định",
          period: "Q3 2024",
          rating: 4.2,
          maxRating: 5,
          categories: {
            productivity: 4,
            quality: 4.5,
            teamwork: 4,
            communication: 4,
            punctuality: 4.5,
          },
          feedback: "Nhân viên có khả năng tốt, cần phát triển thêm.",
          date: "2024-09-20",
        },
      ],
      filterPeriod: "all",
      searchTerm: "",
      selectedEvaluation: null,
    };
  }

  render() {
    const filtered = this.getFilteredEvaluations();

    const evaluationHTML = filtered
      .map(
        (evaluation) => `
      <div class="eval-card glass-effect" data-id="${evaluation.id}">
        <div class="eval-header">
          <div class="emp-info-eval">
            <div class="emp-avatar-eval">${evaluation.employee.charAt(0)}</div>
            <div class="emp-details-eval">
              <h3 class="emp-name-eval">${evaluation.employee}</h3>
              <p class="eval-period">${evaluation.period}</p>
            </div>
          </div>
          <div class="rating-display">
            <span class="rating-value">${evaluation.rating}</span>
            <span class="rating-max">/ ${evaluation.maxRating}</span>
          </div>
        </div>

        <div class="eval-stars">
          ${this.renderStars(evaluation.rating, evaluation.maxRating)}
        </div>

        <div class="eval-categories">
          ${Object.entries(evaluation.categories)
            .map(
              ([key, value]) => `
            <div class="category-item">
              <span class="category-name">${this.getCategoryLabel(key)}</span>
              <div class="category-bar">
                <div class="category-fill" style="width: ${
                  (value / evaluation.maxRating) * 100
                }%"></div>
              </div>
              <span class="category-score">${value}</span>
            </div>
          `
            )
            .join("")}
        </div>

        <div class="eval-feedback">
          <p class="feedback-label">💬 Nhận xét</p>
          <p class="feedback-text">"${evaluation.feedback}"</p>
        </div>

        <div class="eval-meta">
          <span class="eval-evaluator">Đánh giá bởi: ${
            evaluation.evaluator
          }</span>
          <span class="eval-date">${this.formatDate(evaluation.date)}</span>
        </div>

        <div class="eval-actions">
          <button class="btn-view">Xem chi tiết</button>
          <button class="btn-compare">So sánh</button>
        </div>
      </div>
    `
      )
      .join("");

    const avgRating =
      filtered.length > 0
        ? (
            filtered.reduce((sum, e) => sum + e.rating, 0) / filtered.length
          ).toFixed(1)
        : 0;

    const ratingDistribution = this.getRatingDistribution(filtered);

    return `
      <div class="performance-container">
        <div class="performance-header">
          <h1>⭐ Đánh giá hiệu suất</h1>
          <button class="btn btn-primary">+ Tạo đánh giá</button>
        </div>

        <div class="performance-stats">
          <div class="stat-card glass-effect">
            <span class="stat-label">Đánh giá trung bình</span>
            <span class="stat-value">${avgRating}</span>
            <span class="stat-max">/ 5.0</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Tổng đánh giá</span>
            <span class="stat-value">${filtered.length}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Tốt (4+)</span>
            <span class="stat-value excellent">${ratingDistribution.excellent}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Cần cải thiện</span>
            <span class="stat-value low">${ratingDistribution.low}</span>
          </div>
        </div>

        <div class="performance-controls">
          <input
            type="text"
            placeholder="Tìm kiếm nhân viên..."
            class="search-input"
            value="${this.state.searchTerm}"
          />
          <select class="filter-period">
            <option value="all">Tất cả thời kỳ</option>
            <option value="Q4 2024">Q4 2024</option>
            <option value="Q3 2024">Q3 2024</option>
            <option value="Q2 2024">Q2 2024</option>
          </select>
        </div>

        <div class="evaluations-grid">
          ${evaluationHTML}
        </div>

        <style>
          .performance-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .performance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .performance-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .performance-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: var(--space-4);
            margin-bottom: var(--space-6);
          }

          .stat-card {
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            display: flex;
            flex-direction: column;
            gap: var(--space-1);
            text-align: center;
          }

          .stat-label {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .stat-value.excellent {
            color: var(--semantic-green);
          }

          .stat-value.low {
            color: var(--semantic-orange);
          }

          .stat-max {
            font-size: 12px;
            color: var(--text-secondary);
          }

          .performance-controls {
            display: flex;
            gap: var(--space-4);
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
          }

          .search-input,
          .filter-period {
            padding: var(--space-2) var(--space-3);
            background: white;
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .search-input {
            flex: 1;
            min-width: 250px;
          }

          .search-input:focus,
          .filter-period:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .evaluations-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: var(--space-5);
          }

          .eval-card {
            padding: var(--space-5);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            transition: all var(--duration-normal) var(--ease-out);
            display: flex;
            flex-direction: column;
            gap: var(--space-4);
            cursor: pointer;
          }

          .eval-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          }

          .eval-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: var(--space-3);
          }

          .emp-info-eval {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            flex: 1;
          }

          .emp-avatar-eval {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: var(--brand-primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 18px;
            flex-shrink: 0;
          }

          .emp-details-eval {
            flex: 1;
            min-width: 0;
          }

          .emp-name-eval {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
          }

          .eval-period {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .rating-display {
            display: flex;
            align-items: baseline;
            gap: var(--space-1);
          }

          .rating-value {
            font-size: 28px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .rating-max {
            font-size: 12px;
            color: var(--text-secondary);
          }

          .eval-stars {
            display: flex;
            gap: var(--space-1);
            justify-content: flex-start;
          }

          .star {
            font-size: 20px;
          }

          .eval-categories {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
            padding: var(--space-3);
            background: rgba(115, 196, 29, 0.05);
            border-radius: var(--radius-md);
          }

          .category-item {
            display: grid;
            grid-template-columns: 100px 1fr 30px;
            gap: var(--space-3);
            align-items: center;
          }

          .category-name {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
          }

          .category-bar {
            height: 6px;
            background: rgba(115, 196, 29, 0.2);
            border-radius: 3px;
            overflow: hidden;
          }

          .category-fill {
            height: 100%;
            background: var(--brand-primary);
            transition: width var(--duration-normal) var(--ease-out);
          }

          .category-score {
            font-size: 12px;
            font-weight: 700;
            color: var(--brand-primary);
            text-align: right;
          }

          .eval-feedback {
            padding: var(--space-3);
            background: rgba(115, 196, 29, 0.05);
            border-left: 3px solid var(--brand-primary);
            border-radius: var(--radius-md);
          }

          .feedback-label {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            margin: 0 0 var(--space-2) 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .feedback-text {
            font-size: 13px;
            color: var(--text-primary);
            margin: 0;
            font-style: italic;
            line-height: 1.5;
          }

          .eval-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: var(--space-3);
            border-top: 1px solid rgba(0, 0, 0, 0.05);
            font-size: 12px;
            color: var(--text-secondary);
          }

          .eval-evaluator,
          .eval-date {
            font-size: 11px;
          }

          .eval-actions {
            display: flex;
            gap: var(--space-2);
          }

          .btn-view,
          .btn-compare {
            flex: 1;
            padding: var(--space-2) var(--space-3);
            background: var(--neutral-50);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .btn-view:hover,
          .btn-compare:hover {
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
            color: var(--brand-primary);
          }

          @media (max-width: 768px) {
            .performance-container {
              padding: var(--space-4);
            }

            .performance-header {
              flex-direction: column;
              align-items: flex-start;
            }

            .performance-controls {
              flex-direction: column;
            }

            .search-input,
            .filter-period {
              width: 100%;
            }

            .evaluations-grid {
              grid-template-columns: 1fr;
            }

            .category-item {
              grid-template-columns: 80px 1fr 25px;
            }

            .eval-meta {
              flex-direction: column;
              gap: var(--space-2);
              align-items: flex-start;
            }
          }
        </style>
      </div>
    `;
  }

  renderStars(rating, maxRating) {
    let stars = "";
    for (let i = 1; i <= maxRating; i++) {
      if (i <= Math.floor(rating)) {
        stars += '<span class="star">★</span>';
      } else if (i - 0.5 <= rating) {
        stars += '<span class="star">◆</span>';
      } else {
        stars += '<span class="star">☆</span>';
      }
    }
    return stars;
  }

  getCategoryLabel(key) {
    const labels = {
      productivity: "Năng suất",
      quality: "Chất lượng",
      teamwork: "Làm việc nhóm",
      communication: "Giao tiếp",
      punctuality: "Kỷ luật",
    };
    return labels[key] || key;
  }

  getRatingDistribution(evaluations) {
    return {
      excellent: evaluations.filter((e) => e.rating >= 4).length,
      good: evaluations.filter((e) => e.rating >= 3 && e.rating < 4).length,
      low: evaluations.filter((e) => e.rating < 3).length,
    };
  }

  getFilteredEvaluations() {
    return this.state.evaluations.filter((evaluation) => {
      const matchesSearch = evaluation.employee
        .toLowerCase()
        .includes(this.state.searchTerm.toLowerCase());
      const matchesPeriod =
        this.state.filterPeriod === "all" ||
        evaluation.period === this.state.filterPeriod;
      return matchesSearch && matchesPeriod;
    });
  }

  formatDate(dateStr) {
    const date = new Date(dateStr + "T00:00:00");
    return date.toLocaleDateString("vi-VN");
  }

  onMount() {
    const searchInput = this.el.querySelector(".search-input");
    const filterPeriod = this.el.querySelector(".filter-period");
    const evalCards = this.el.querySelectorAll(".eval-card");

    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchTerm = e.target.value;
        this.render();
      });
    }

    if (filterPeriod) {
      filterPeriod.addEventListener("change", (e) => {
        this.state.filterPeriod = e.target.value;
        this.render();
      });
    }

    if (evalCards) {
      evalCards.forEach((card) => {
        card.addEventListener("click", () => {
          const id = card.dataset.id;
          this.state.selectedEvaluation = id;
          console.log("Selected evaluation:", id);
        });
      });
    }

    console.log("✅ Performance Management component mounted");
  }

  onUnmount() {
    console.log("✅ Performance Management component unmounted");
  }
}
