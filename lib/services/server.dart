import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
          {

              "type": "service_account",
              "project_id": "fans-food-stf",
              "private_key_id": "ecb9697b0a82f9f4f429a07ccec06e12e06dd256",
              "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClY72F6WdpfrDR\n5s0/ZmxJqUnDoxo3mC6zEtxPH2cdYpWQ1t5OrtamMUAEc1V8YDtU83xb5cIaYzo7\nqCGPIbMfeW8WJWH9skigLDB2G+VMcxSr6rXJH5wa9GzKWy6ycxMDs4TwsMy0RJ0M\nDytVrTZQ+C3myrYO4W2ea7l41NQZxSf4veN6zNPz6Z0E85PmCfQjqIgOGuHEAGpk\nEZSgeDAmAe6BJ2SeAkTh1pTo8g5WGEGzrArrk1ndbvGClM4FcWoTjZe9Io8c5KuO\n6vrTwxFEOSOWCSA4b1fRtsrBhC5ck2fVZxDqQbkPYu5dBUZYK7oBaNUg57x0c3CV\nhfVet0dXAgMBAAECggEAS7JkXoOO6LprHI8J9tAelPJOCCRBDhvxl9V0jyQ80ja6\nZOHrOtEL/mHBPqg5AqWa0k1k6Dy3A9PRpddUkMmoTaoLPXQbrv1n/yNqhMxMvRpY\n5jyVOjnk/XNMzatBKry/gayrFmydLI7Q4GGbAGo4V4PXom+6NwJXZTBB4ftrHmWh\nEalvbcOP9NOo6Da2JTziSzsq2M2gO+oZiJSzfbxwT9zGUpsfc38Od8bB5en7qooA\n6f0eHeXRotLaxYkYetI8F2zKbgzVKwYcMAlcMlMwAWsotjvqsaAiA6mbcDNYdORF\nlZNjAVuL/NQX8nOVGFcVIo7qiblytUMzjimC6ExQ+QKBgQDccM7x+sz552U4M8Rm\n2iSnKgU7tWiYConiGr3EqkcEWmfLaeVzgJjZDe6svvEkkKSon77IRN5WAbSVfWT/\nz00I7DtlX+bwx9nIx453TwnP8BbtdK7lJ4epiUj2s2JjXx6JdsYBwFg2EnYUWJeX\nm0Pvxb384mzDyDvu//ATi2qg+QKBgQDAEZNH5OmrHR2x33qPI7T/r0jfkrTZGfK/\n9d+6aqXA5HeKWicAeea+Z+Tnzd1pqqN8b4zEYadx2v+TCQqPccNZqKoF/nzm8z8M\nL/yfAKoPjcrF8ZZf8IE7/2bMmhNuni/borbaB4aXsaupckkmVqAG4hMnZ9odpsJ8\nQofC0h2OzwKBgHM6/NJ8+b0AembAmL/y9An16zpk/8HKcH0i4WP2Zp0d7Pfl6S1R\nYZTEtajTPxaQDaKfrojdhyOKTK2AGNWntWseoYXCdeQTdAKCXjR7unNZ24JQ5kOf\nQEkdHGjpKFstk7bjwWmU9Ad/6v2DuepkHUUvJrsUWSqWds3eN87fp+NxAoGBAKWC\nv7M1jTL6bStplDijIYcv6pFW3+cx2CEZZQlEe7+kYWrk0zUy1ud/qh8jJMi41hcW\nHWzhZiTT/mcbZHFGLHwnvxRZQBLYzJzZAU2XifTLUFCRJe9Y1lT4ewKXR2WMhVs0\ndXOfBpnT7kSfim+yOEaWLMFJWgkxOelQf6Mf4367AoGAFFLE1nKnOoxOS+mUTB2t\nxy/B7IcygPEE3QbWNyUakLjcetjnbX4tuYAvwouXYrm/Zt2SSrxq6pqCs0oTGLMg\nuZla8XcgpQ36a8s/LE2Zeu3RGI9+uMLlJrzHogdTcRK0JnN0V8Y3QGnT1aFPIbja\nLcNWUWzxqTI5Cb6KZO2Kfh4=\n-----END PRIVATE KEY-----\n",
              "client_email": "firebase-adminsdk-fbsvc@fans-food-stf.iam.gserviceaccount.com",
              "client_id": "107810596395654139498",
              "auth_uri": "https://accounts.google.com/o/oauth2/auth",
              "token_uri": "https://oauth2.googleapis.com/token",
              "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
              "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40fans-food-stf.iam.gserviceaccount.com",
              "universe_domain": "googleapis.com"


          }

      ),
      scopes,
    );

    final accessToken = client.credentials.accessToken.data;
    print('accesstokeennnnnnnn......:$accessToken');
    return accessToken;
  }
}