window.addEventListener("message", (event) => {
    const data = event.data
  
    if (data.action === "show") {
      document.getElementById("protection-container").style.display = "block"
      document.getElementById("logo").src = data.logo
      document.getElementById("title").textContent = data.title
      document.getElementById("timer-text").textContent = data.timerText
      document.getElementById("timer").textContent = data.minutes
      document.getElementById("protection-text").textContent = data.protectionText
      document.getElementById("reward-amount").textContent = data.rewardAmount.toLocaleString()
      document.getElementById("reward-text").textContent = data.rewardText
    } else if (data.action === "hide") {
      document.getElementById("protection-container").style.display = "none"
    } else if (data.action === "updateTimer") {
      document.getElementById("timer").textContent = data.minutes
      if (data.minutes <= 0) {
        document.getElementById("protection-container").style.display = "none"
      }
    }
  })
  
  