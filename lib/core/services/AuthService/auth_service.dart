// class AuthService {
//   final HttpService http;

//   AuthService(this.http);

//   Future<void> sendRegisterOtp({
//     required String email,
//     required String username,
//   }) {
//     return http.post(
//       '/api/auth/send-email-otp',
//       body: {
//         'email': email,
//         'username': username,
//       },
//     );
//   }
// }
