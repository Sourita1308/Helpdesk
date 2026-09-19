/**
 * HelpDesk Lite - Interactive Operations & SLA Countdown Timers
 */

document.addEventListener('DOMContentLoaded', () => {
  if (window.lucide) {
    window.lucide.createIcons();
  }
  initSlaTimers();
  initAutoDismissAlerts();
});

// Live SLA countdown ticker
function initSlaTimers() {
  const slaElements = document.querySelectorAll('[data-sla-deadline]');
  if (!slaElements.length) return;

  function updateTimers() {
    const now = new Date().getTime();

    slaElements.forEach(el => {
      const isResolved = el.getAttribute('data-sla-resolved') === 'true';
      if (isResolved) {
        el.textContent = 'Met SLA';
        el.className = 'sla-pill resolved';
        return;
      }

      const deadlineStr = el.getAttribute('data-sla-deadline');
      const deadline = new Date(deadlineStr).getTime();
      const diff = deadline - now;

      if (diff <= 0) {
        // Breached
        const absDiff = Math.abs(diff);
        const hours = Math.floor(absDiff / (1000 * 60 * 60));
        const mins = Math.floor((absDiff % (1000 * 60 * 60)) / (1000 * 60));
        const secs = Math.floor((absDiff % (1000 * 60)) / 1000);
        el.textContent = `Breached by ${hours}h ${mins}m ${secs}s`;
        el.className = 'sla-pill breached';
      } else {
        // Active Countdown
        const hours = Math.floor(diff / (1000 * 60 * 60));
        const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const secs = Math.floor((diff % (1000 * 60)) / 1000);

        el.textContent = `${hours}h ${mins}m ${secs}s left`;

        if (diff < 3600000) { // < 1 hour
          el.className = 'sla-pill urgent';
        } else if (diff < 7200000) { // < 2 hours
          el.className = 'sla-pill warning';
        } else {
          el.className = 'sla-pill normal';
        }
      }
    });
  }

  updateTimers();
  setInterval(updateTimers, 1000);
}

// Fade out alerts after 5 seconds
function initAutoDismissAlerts() {
  const alerts = document.querySelectorAll('.alert-banner');
  alerts.forEach(alert => {
    setTimeout(() => {
      alert.style.transition = 'opacity 0.5s ease';
      alert.style.opacity = '0';
      setTimeout(() => alert.remove(), 500);
    }, 6000);
  });
}
