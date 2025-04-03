document.getElementById("loginForm").addEventListener("submit", function(event) {
    event.preventDefault(); // Prevent form submission

    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    const errorMessage = document.getElementById("error-message");

    // Dummy authentication (Replace with actual backend validation)
    if (email === "test@smartstocksx.com" && password === "password123") {
        alert("Login successful!");
        window.location.href = "dashboard.html"; // Redirect to dashboard page
    } else {
        errorMessage.classList.remove("d-none"); // Show error message
    }
});
