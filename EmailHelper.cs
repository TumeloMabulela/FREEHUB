using System;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace FreeHubProject
{
    public static class EmailHelper
    {
        // ============================================================
        // CONFIGURE THESE WITH YOUR GMAIL CREDENTIALS
        // To use Gmail: 
        //   1. Go to myaccount.google.com > Security > 2-Step Verification (enable it)
        //   2. Then go to App passwords > Create one for "Mail"
        //   3. Paste the 16-character password below
        // ============================================================
        private static readonly string SmtpEmail = "your-email@gmail.com";      // <-- Replace with your Gmail
        private static readonly string SmtpPassword = "your-app-password";       // <-- Replace with App Password
        private static readonly string SmtpHost = "smtp.gmail.com";
        private static readonly int SmtpPort = 587;
        private static readonly string FromName = "FreeHUB";

        /// <summary>
        /// Sends an email using configured SMTP settings.
        /// </summary>
        public static bool SendEmail(string toEmail, string subject, string htmlBody)
        {
            try
            {
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(SmtpEmail, FromName);
                    mail.To.Add(toEmail);
                    mail.Subject = subject;
                    mail.Body = htmlBody;
                    mail.IsBodyHtml = true;

                    using (var smtp = new SmtpClient(SmtpHost, SmtpPort))
                    {
                        smtp.Credentials = new NetworkCredential(SmtpEmail, SmtpPassword);
                        smtp.EnableSsl = true;
                        smtp.Send(mail);
                    }
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        /// Sends a verification email to the user after registration.
        /// </summary>
        public static bool SendVerificationEmail(string toEmail, string token)
        {
            string baseUrl = GetBaseUrl();
            string verifyLink = baseUrl + "VerifyEmail.aspx?token=" + HttpUtility.UrlEncode(token);

            string subject = "Verify your FreeHUB account";
            string body = $@"
                <div style='font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 30px; background: #f5f7f5; border-radius: 12px;'>
                    <div style='text-align: center; margin-bottom: 24px;'>
                        <h1 style='color: #173f2c; font-size: 24px; margin: 0;'>Free<span style='color: #6b9b37;'>HUB</span></h1>
                    </div>
                    <div style='background: white; padding: 30px; border-radius: 10px; border: 1px solid #e8ece8;'>
                        <h2 style='color: #173f2c; font-size: 20px; margin-top: 0;'>Verify your email address</h2>
                        <p style='color: #555; font-size: 14px; line-height: 1.6;'>
                            Thanks for creating a FreeHUB account! Please click the button below to verify your email address.
                        </p>
                        <div style='text-align: center; margin: 28px 0;'>
                            <a href='{verifyLink}' style='background-color: #173f2c; color: white; padding: 14px 32px; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 14px; display: inline-block;'>
                                Verify Email
                            </a>
                        </div>
                        <p style='color: #888; font-size: 12px; line-height: 1.5;'>
                            If the button doesn't work, copy and paste this link into your browser:<br/>
                            <a href='{verifyLink}' style='color: #2563eb;'>{verifyLink}</a>
                        </p>
                    </div>
                    <p style='color: #999; font-size: 11px; text-align: center; margin-top: 16px;'>
                        If you didn't create an account, you can ignore this email.
                    </p>
                </div>";

            return SendEmail(toEmail, subject, body);
        }

        /// <summary>
        /// Sends a password reset email with a time-limited link.
        /// </summary>
        public static bool SendPasswordResetEmail(string toEmail, string token)
        {
            string baseUrl = GetBaseUrl();
            string resetLink = baseUrl + "ResetPassword.aspx?token=" + HttpUtility.UrlEncode(token);

            string subject = "Reset your FreeHUB password";
            string body = $@"
                <div style='font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 30px; background: #f5f7f5; border-radius: 12px;'>
                    <div style='text-align: center; margin-bottom: 24px;'>
                        <h1 style='color: #173f2c; font-size: 24px; margin: 0;'>Free<span style='color: #6b9b37;'>HUB</span></h1>
                    </div>
                    <div style='background: white; padding: 30px; border-radius: 10px; border: 1px solid #e8ece8;'>
                        <h2 style='color: #173f2c; font-size: 20px; margin-top: 0;'>Reset your password</h2>
                        <p style='color: #555; font-size: 14px; line-height: 1.6;'>
                            We received a request to reset your password. Click the button below to choose a new password. This link expires in 1 hour.
                        </p>
                        <div style='text-align: center; margin: 28px 0;'>
                            <a href='{resetLink}' style='background-color: #173f2c; color: white; padding: 14px 32px; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 14px; display: inline-block;'>
                                Reset Password
                            </a>
                        </div>
                        <p style='color: #888; font-size: 12px; line-height: 1.5;'>
                            If the button doesn't work, copy and paste this link:<br/>
                            <a href='{resetLink}' style='color: #2563eb;'>{resetLink}</a>
                        </p>
                    </div>
                    <p style='color: #999; font-size: 11px; text-align: center; margin-top: 16px;'>
                        If you didn't request a password reset, you can ignore this email.
                    </p>
                </div>";

            return SendEmail(toEmail, subject, body);
        }

        /// <summary>
        /// Generates a unique token for verification or password reset.
        /// </summary>
        public static string GenerateToken()
        {
            return Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N").Substring(0, 8);
        }

        private static string GetBaseUrl()
        {
            var request = HttpContext.Current.Request;
            string baseUrl = request.Url.Scheme + "://" + request.Url.Authority +
                             request.ApplicationPath.TrimEnd('/') + "/";
            return baseUrl;
        }
    }
}
