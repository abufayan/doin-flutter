import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/widgets/doin_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> wait() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // wait();
    // Check auth status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is SessionRestored) {
          await wait();
          context.router.replaceAll([const HomeRoute()]);
        } else {
          await wait();
          context.router.replaceAll([const LoginOrRegisterRoute()]);
        }

        // if (state is AuthUnauthenticated) {
        //   context.router.replaceAll([const LoginRoute()]);
        // }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: .center,
              children: [
                // Logo + App name
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    DoinDesign()
                  ],
                ),

                const SizedBox(height: 40),

                // Welcome text
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 22),
                    children: [
                      TextSpan(
                        text: 'Welcome to ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Doin FX',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Optional loader
                AppLoaders.loadingIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
