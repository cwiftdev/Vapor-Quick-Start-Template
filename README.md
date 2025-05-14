# 🚀 Swift Vapor Starter Template

A modern, production-ready Vapor template built with **Swift 6.0** and `async/await` support. Ideal for building scalable, secure, and localized back-end services in Swift.

---

## ✨ Features

### 1. JWT-based authentication 🔐
This template utilizes JWT-based authentication. The access tokens are used as JWTs. The authentication implementation is inspired by the [Vapor Auth Template](https://github.com/madsodgaard/vapor-auth-template) repository.

The following services have been implemented:
- Login
- Register
- Token Generation
- Reset Password Flow
- Email Verification Flow

### 2. Email Sending 📬
Email sending functionality has been implemented using [VaporSMTPKit](https://github.com/Joannis/VaporSMTPKit). The email sending process is managed using [Vapor Redis Queue Driver](https://github.com/vapor/queues-redis-driver).

### 3. Server-side Localization 🌍
Server-side localization is supported. By integrating [Lingo](https://github.com/vapor-community/Lingo-Vapor), you can add multi-language support to email sending processes or responses, enabling the creation of globally-based projects.

### 4. Testability 🧪
Incoming requests are processed within the UseCase layer. The services and business logic are developed with a protocol-oriented approach, ensuring a testable project. **Existing workflows have been covered with unit testing**. You can also integrate IntegrationTests or SmokeTests to handle migrations etc.

## 🛠️ Requirements
- Swift 6.0+
- Vapor
- PostgreSQL
- Redis 
- An SMTP email provider (e.g., Mailgun, SendGrid, Gmail)

---

## 🚀 Getting Started

### Create Your Own Project

Choose one of the following options:

- 📦 **Use this template** (recommended):  
  Click the green **"Use this template"** button to create a new repository based on this template.

- 🍴 **Fork this repository**:  
  Useful if you want to contribute or maintain sync with upstream changes.

- 🧱 **Clone directly**:
```bash
git clone https://github.com/cwiftdev/Vapor-Quick-Start-Template/
cd Vapor-Quick-Start-Template
```

### Configure Environment Variables
 file or set variables via shell for development, testing and production environment
To configure environment variables, you should [create a separate .env](https://docs.vapor.codes/basics/environment/#env-dotenv) file for each environment, such as development or production, depending on where the application is running. No separate .env file is needed for the testing environment.:

```env
DATABASE_URL=postgres://<username>:<password if exists>@localhost:5432/<db name>
CLIENT_URL=<Your Client URL>
JWKS=<Trimmed JWKS Key>
API_URL=<Your API Url>
SMTP_HOST=<SMTP Host>
SMTP_MAIL=<SMTP Mail>
SMTP_PASSWORD=<SMTP Password>
REDIS_URL=<REDIS URL>
```
## API Endpoints and cURL Examples

Below are the API endpoints and cURL examples for different authentication services. These examples can be used for both local testing and production.

| **Service**                  | **Description**                                                        | **cURL Example**                                                                                                                                           |
|------------------------------|------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Register**                  | Register a new user with email and password.                           | `curl --location 'http://localhost:8080/authentication/register' \--header 'Accept-Language: en-US' \--header 'Content-Type: application/json' \--data-raw '{"email": "test@gmail.com",    "password": "Test12345.", "confirmPassword": "Test12345."}'`                    |
| **Login**                     | Authenticate a user and get a JWT access token.                       | `curl --location 'http://localhost:8080/authentication/login' \--header 'Accept-Language: en-US' \--header 'Content-Type: application/json' \--data-raw '{"email": "test@gmail.com", "password": "Test12345."}'`                                       |
| **Token**                     | Generate a new access token using a refresh token.                    | `curl --location 'http://localhost:8080/authentication/token' \--header 'Content-Type: application/json' \--header 'Accept-Language: en-US' \--data '{"refreshToken": "Your-refresh-token"}'`                                  |
| **Reset Password Request**    | Request a password reset email for the user.                          | `curl --location 'http://localhost:8080/authentication/reset-password/send' \--header 'Accept-Language: en-US' \--header 'Content-Type: application/json' \--data-raw '{"email": "test@gmail.com"}'`                                             |
| **Reset Password Token Verify** | Verify the password reset token sent to the user's email.              | `curl --location --request GET 'http://localhost:8080/authentication/reset-password/verify?token=<Your Token>' \--header 'Content-Type: application/json' \--header 'Accept-Language: en-US' \--data-raw '{"email": "test@gmail.com"}'`                                                 |
| **Reset Password**            | Reset the user's password using a valid reset token.                  | `curl --location --request PUT 'http://localhost:8080/authentication/reset-password/reset' \--header 'Content-Type: application/json' \--header 'Accept-Language: en-US' \--data '{"password": "NewTest12345.", "confirmPassword": "NewTest12345.", "token": "Your reset password token"}'` |
| **Send Email Verification**   | Send an email verification link to the user's email.                  | `curl --location 'http://localhost:8080/authentication/email-verification' \--header 'Content-Type: application/json' \--header 'Accept-Language: en-US' \--data-raw '{    "email": "test@gmail.com"}'`                                |
| **Verify Email**              | Verify the email address using the verification token.                | `curl --location 'http://localhost:8080/authentication/email-verification?token=<Your Token>' \--header 'Accept-Language: en-US'`  


## 👨‍💻 Author

Developed and maintained by [cwiftdev](https://github.com/cwiftdev)  
Feel free to open issues or discuss improvements.

---

## 🏷️ Tags

`Swift`, `Vapor`, `JWT`, `SMTP`, `Localization`, `Backend`, `Swift 6`, `Starter Template`
