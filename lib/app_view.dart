import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_connect/screens/view/user/subPages/edit_profile.dart';
import 'app_start_redirector.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'package:provider/provider.dart';

import 'package:user_repository/user_repository.dart';
import 'package:help_connect/screens/firstScreen.dart';
import 'package:help_connect/screens/auth/views/sign_in_screen.dart';
import 'package:help_connect/screens/auth/views/sign_up_screen.dart';
import 'package:help_connect/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:help_connect/screens/auth/blocs/sign_up_bloc/sign_up_bloc.dart';

import 'chat/chatbot/chat_bot_page.dart';
import 'chat/chatweb_socker/chat_list_screen.dart';
import 'screens/view/admin/sub_pages/tab/home/users_page.dart';
import 'screens/view/business/verification/business_verification_screen.dart';
import 'screens/view/business/view/main_pages/account_bn.dart';
import 'screens/view/business/view/main_pages/completed_campaigns.dart';
import 'screens/view/business/view/main_pages/create_help_request.dart';
import 'screens/view/business/view/main_pages/home_business.dart';
import 'screens/view/business/view/main_pages/my_campaigns_screen.dart';
import 'screens/view/user/main_pages/landing_page.dart';
import 'screens/view/user/main_pages/NewsFeedPage.dart';
import 'screens/view/user/main_pages/SupportPage.dart';
import 'screens/view/user/main_pages/profile_screen.dart';
import 'screens/view/user/subPages/verification/identity_verification.dart';
import 'screens/view/user/subPages/privacy_policy_screen.dart';
import 'screens/view/user/widgets/bookmarked.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) =>
              AuthenticationBloc(userRepository: userRepository),
        ),
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(userRepository),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(userRepository),
        ),
        ChangeNotifierProvider(
            create: (_) => BookmarkProvider()..loadBookmarkedEvents()),
      ],
      child: MaterialApp(
        title: 'Ứng dụng tình nguyện',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.orange.shade50,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/',
        routes: {
          '/first': (context) => FirstScreen(),
          '/landing': (context) => LandingPage(),
          '/verify': (context) => IdentityVerificationPage(),
          '/register':(context) => BlocProvider(
            create: (context) => SignInBloc(
              RepositoryProvider.of<UserRepository>(context),
            ),
            child: SignInScreen(),
          ),
          '/login': (context) => SignUpScreen(userType: 'user'),
          '/privacy-policy': (context) => PrivacyPolicyScreen(),
          '/support': (context) => SupportPage(),
          '/newsfeed': (context) => NewsFeedPage(),
          '/profile': (context) => ProfileScreen(),
          '/business_verification': (context) => BusinessVerificationScreen(),
          '/user_page': (context) => UsersPage(),
          '/chat': (context) => ChatBotPage(),
          '/chatweb': (context) => ChatListScreen(),
          '/edit-profile': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is MyUser) {
              return EditProfilePage(user: args);
            } else {
              return Scaffold(
                body: Center(child: Text("unable_to_open_profile_edit_page".tr())),
              );
            }
          },
          '/partner-home': (context) => PartnerHomePage(),
          '/create-request_BN': (context) {
            final user = FirebaseAuth.instance.currentUser;
            return CreateHelpPage(
              userEmail: user?.email ?? "userNotLoggedIn".tr(),
              userName: user?.displayName ?? "user".tr(),
              onSubmit: (requestData) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("request_sent_successfully".tr()),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              onCampaignCreated: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("new_campaign_created".tr()),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushReplacementNamed(context, '/partner-home');
              },
            );
          },
          '/my-campaigns': (context) => MyCampaignsScreen(),
          '/completed-campaigns': (context) => CompletedCampaigns(),
          '/account': (context) => AccountBn(),
        },
        home: AppStartRedirector(),
      ),
    );
  }
}
