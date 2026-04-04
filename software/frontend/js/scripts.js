document.getElementById("login-form").addEventListener("submit", async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = {
        username: formData.get("username"),
        password: formData.get("password")
    };
    console.log("Pre sending the Post request with data:", data);
    try {
        const response = await fetch("/api/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ username: "mhiaghi", password: "1234" })
        });
        if (response.ok) {
            const result = await response.json();
            document.getElementById("response").innerText = result.message;
        }
    } catch (error) {
        console.error("Error:", error);
        document.getElementById("response").innerText = "An error occurred. Please try again.";
    }
});

document.getElementById("signin-form").addEventListener("submit", async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = {
        username: formData.get("username"),
        password: formData.get("password")
    };
    try {
        const response = await fetch("/api/signin", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        });
        if (response.ok) {
            const result = await response.json();
            document.getElementById("response").innerText = result.message;
        }
    } catch (error) {
        console.error("Error:", error);
        document.getElementById("response").innerText = "An error occurred. Please try again.";
    }
});
