// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hello`
  String get hello {
    return Intl.message(
      'Hello',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to eat today?`
  String get what_do_you_want_to_eat_today {
    return Intl.message(
      'What do you want to eat today?',
      name: 'what_do_you_want_to_eat_today',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get Search {
    return Intl.message(
      'Search',
      name: 'Search',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `fast food`
  String get fastfood {
    return Intl.message(
      'fast food',
      name: 'fastfood',
      desc: '',
      args: [],
    );
  }

  /// `seafood`
  String get seafood {
    return Intl.message(
      'seafood',
      name: 'seafood',
      desc: '',
      args: [],
    );
  }

  /// `sweets`
  String get sweets {
    return Intl.message(
      'sweets',
      name: 'sweets',
      desc: '',
      args: [],
    );
  }

  /// `drinks`
  String get drinks {
    return Intl.message(
      'drinks',
      name: 'drinks',
      desc: '',
      args: [],
    );
  }

  /// `favourits`
  String get favourits {
    return Intl.message(
      'favourits',
      name: 'favourits',
      desc: '',
      args: [],
    );
  }

  /// `orders`
  String get orders {
    return Intl.message(
      'orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `settings`
  String get settings {
    return Intl.message(
      'settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `admin panel`
  String get admin_panel {
    return Intl.message(
      'admin panel',
      name: 'admin_panel',
      desc: '',
      args: [],
    );
  }

  /// `profile`
  String get profile {
    return Intl.message(
      'profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `contact us`
  String get contact_us {
    return Intl.message(
      'contact us',
      name: 'contact_us',
      desc: '',
      args: [],
    );
  }

  /// `logout`
  String get logout {
    return Intl.message(
      'logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `login`
  String get login {
    return Intl.message(
      'login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get PersonalInformation {
    return Intl.message(
      'Personal Information',
      name: 'PersonalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get Phone {
    return Intl.message(
      'Phone',
      name: 'Phone',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get Email {
    return Intl.message(
      'Email',
      name: 'Email',
      desc: '',
      args: [],
    );
  }

  /// `Saved Addresses`
  String get Address {
    return Intl.message(
      'Saved Addresses',
      name: 'Address',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get Edit {
    return Intl.message(
      'Edit',
      name: 'Edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Add New Address`
  String get add_address {
    return Intl.message(
      'Add New Address',
      name: 'add_address',
      desc: '',
      args: [],
    );
  }

  /// `No addresses saved yet`
  String get Naddresses {
    return Intl.message(
      'No addresses saved yet',
      name: 'Naddresses',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get AddAddress {
    return Intl.message(
      'Add Address',
      name: 'AddAddress',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get delete_account {
    return Intl.message(
      'Delete Account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get default1 {
    return Intl.message(
      'Default',
      name: 'default1',
      desc: '',
      args: [],
    );
  }

  /// `Address Title (e.g. Home, Work, etc.)`
  String get AddressTitle {
    return Intl.message(
      'Address Title (e.g. Home, Work, etc.)',
      name: 'AddressTitle',
      desc: '',
      args: [],
    );
  }

  /// `Full Address`
  String get FullAddress {
    return Intl.message(
      'Full Address',
      name: 'FullAddress',
      desc: '',
      args: [],
    );
  }

  /// `Set as default address`
  String get Setdefaultaddress {
    return Intl.message(
      'Set as default address',
      name: 'Setdefaultaddress',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all fields`
  String get Pleasefill {
    return Intl.message(
      'Please fill all fields',
      name: 'Pleasefill',
      desc: '',
      args: [],
    );
  }

  /// `Save Address`
  String get SaveAddress {
    return Intl.message(
      'Save Address',
      name: 'SaveAddress',
      desc: '',
      args: [],
    );
  }

  /// `Edit Address`
  String get EditAddress {
    return Intl.message(
      'Edit Address',
      name: 'EditAddress',
      desc: '',
      args: [],
    );
  }

  /// `Update Address`
  String get UpdateAddress {
    return Intl.message(
      'Update Address',
      name: 'UpdateAddress',
      desc: '',
      args: [],
    );
  }

  /// `Delete Address`
  String get DeleteAddress {
    return Intl.message(
      'Delete Address',
      name: 'DeleteAddress',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this address?`
  String get suredeleteaddress {
    return Intl.message(
      'Are you sure you want to delete this address?',
      name: 'suredeleteaddress',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get Profileupdatedsuccessfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'Profileupdatedsuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Update Profile`
  String get UpdateProfile {
    return Intl.message(
      'Update Profile',
      name: 'UpdateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.`
  String get Areyoudeleteaccount {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
      name: 'Areyoudeleteaccount',
      desc: '',
      args: [],
    );
  }

  /// `Final Confirmation`
  String get FinalConfirmation {
    return Intl.message(
      'Final Confirmation',
      name: 'FinalConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `This will permanently delete your account, including order history, saved addresses, and personal information. Are you absolutely sure?`
  String get Thiswillpermanentlydeleteyouraccount {
    return Intl.message(
      'This will permanently delete your account, including order history, saved addresses, and personal information. Are you absolutely sure?',
      name: 'Thiswillpermanentlydeleteyouraccount',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Delete My Account`
  String get YesDeleteMyAccount {
    return Intl.message(
      'Yes, Delete My Account',
      name: 'YesDeleteMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must be 11 digits`
  String get phoneverfy {
    return Intl.message(
      'Phone number must be 11 digits',
      name: 'phoneverfy',
      desc: '',
      args: [],
    );
  }

  /// `Loading restaurants...`
  String get loadingres {
    return Intl.message(
      'Loading restaurants...',
      name: 'loadingres',
      desc: '',
      args: [],
    );
  }

  /// `No orders yet`
  String get noorders {
    return Intl.message(
      'No orders yet',
      name: 'noorders',
      desc: '',
      args: [],
    );
  }

  /// `Your order history will appear here`
  String get yourorderhistorywillappearhere {
    return Intl.message(
      'Your order history will appear here',
      name: 'yourorderhistorywillappearhere',
      desc: '',
      args: [],
    );
  }

  /// `Your Orders`
  String get yourorders {
    return Intl.message(
      'Your Orders',
      name: 'yourorders',
      desc: '',
      args: [],
    );
  }

  /// `You have`
  String get youhave {
    return Intl.message(
      'You have',
      name: 'youhave',
      desc: '',
      args: [],
    );
  }

  /// `order`
  String get order {
    return Intl.message(
      'order',
      name: 'order',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Customer',
      name: 'customer',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderdetails {
    return Intl.message(
      'Order Details',
      name: 'orderdetails',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get egp {
    return Intl.message(
      'EGP',
      name: 'egp',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get delivered {
    return Intl.message(
      'Delivered',
      name: 'delivered',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Light Mode`
  String get light_mode {
    return Intl.message(
      'Light Mode',
      name: 'light_mode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message(
      'Preferences',
      name: 'preferences',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to continue`
  String get sign_in_to_continue {
    return Intl.message(
      'Sign in to continue',
      name: 'sign_in_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get enter_email {
    return Intl.message(
      'Enter your email',
      name: 'enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enter_password {
    return Intl.message(
      'Enter your password',
      name: 'enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgot_password {
    return Intl.message(
      'Forgot Password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `LOG IN`
  String get log_in_button {
    return Intl.message(
      'LOG IN',
      name: 'log_in_button',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message(
      'OR',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Google`
  String get google {
    return Intl.message(
      'Google',
      name: 'google',
      desc: '',
      args: [],
    );
  }

  /// `Apple`
  String get apple {
    return Intl.message(
      'Apple',
      name: 'apple',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dont_have_account {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dont_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign up to get started`
  String get sign_up_to_get_started {
    return Intl.message(
      'Sign up to get started',
      name: 'sign_up_to_get_started',
      desc: '',
      args: [],
    );
  }

  /// `Sign up with`
  String get sign_up_with {
    return Intl.message(
      'Sign up with',
      name: 'sign_up_with',
      desc: '',
      args: [],
    );
  }

  /// `Enter your full name`
  String get enter_full_name {
    return Intl.message(
      'Enter your full name',
      name: 'enter_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get enter_phone {
    return Intl.message(
      'Enter your phone number',
      name: 'enter_phone',
      desc: '',
      args: [],
    );
  }

  /// `Create a password`
  String get create_password {
    return Intl.message(
      'Create a password',
      name: 'create_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your password`
  String get confirm_password {
    return Intl.message(
      'Confirm your password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get terms_and_conditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'terms_and_conditions',
      desc: '',
      args: [],
    );
  }

  /// `SIGN UP`
  String get sign_up_button {
    return Intl.message(
      'SIGN UP',
      name: 'sign_up_button',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get already_have_account {
    return Intl.message(
      'Already have an account?',
      name: 'already_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get log_in {
    return Intl.message(
      'Log In',
      name: 'log_in',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get name_required {
    return Intl.message(
      'Name is required',
      name: 'name_required',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get email_required {
    return Intl.message(
      'Email is required',
      name: 'email_required',
      desc: '',
      args: [],
    );
  }

  /// `Phone is required`
  String get phone_required {
    return Intl.message(
      'Phone is required',
      name: 'phone_required',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must be 11 digits`
  String get phone_length_error {
    return Intl.message(
      'Phone number must be 11 digits',
      name: 'phone_length_error',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get password_required {
    return Intl.message(
      'Password is required',
      name: 'password_required',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get password_length_error {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'password_length_error',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwords_not_match {
    return Intl.message(
      'Passwords do not match',
      name: 'passwords_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Password confirmation is required`
  String get password_confirm_required {
    return Intl.message(
      'Password confirmation is required',
      name: 'password_confirm_required',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout_title {
    return Intl.message(
      'Logout',
      name: 'logout_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logout_confirm {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logout_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Cart`
  String get cart {
    return Intl.message(
      'Cart',
      name: 'cart',
      desc: '',
      args: [],
    );
  }

  /// `Your cart is empty`
  String get cart_empty {
    return Intl.message(
      'Your cart is empty',
      name: 'cart_empty',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart`
  String get add_to_cart {
    return Intl.message(
      'Add to Cart',
      name: 'add_to_cart',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Cart`
  String get remove_from_cart {
    return Intl.message(
      'Remove from Cart',
      name: 'remove_from_cart',
      desc: '',
      args: [],
    );
  }

  /// `Clear Cart`
  String get clear_cart {
    return Intl.message(
      'Clear Cart',
      name: 'clear_cart',
      desc: '',
      args: [],
    );
  }

  /// `Cart Total`
  String get cart_total {
    return Intl.message(
      'Cart Total',
      name: 'cart_total',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get reviews {
    return Intl.message(
      'Reviews',
      name: 'reviews',
      desc: '',
      args: [],
    );
  }

  /// `Write a Review`
  String get write_review {
    return Intl.message(
      'Write a Review',
      name: 'write_review',
      desc: '',
      args: [],
    );
  }

  /// `No reviews yet`
  String get no_reviews {
    return Intl.message(
      'No reviews yet',
      name: 'no_reviews',
      desc: '',
      args: [],
    );
  }

  /// `Rate your experience`
  String get rate_your_experience {
    return Intl.message(
      'Rate your experience',
      name: 'rate_your_experience',
      desc: '',
      args: [],
    );
  }

  /// `Your review`
  String get your_review {
    return Intl.message(
      'Your review',
      name: 'your_review',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get confirm_exit {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'confirm_exit',
      desc: '',
      args: [],
    );
  }

  /// `Any unsaved changes will be lost`
  String get confirm_exit_message {
    return Intl.message(
      'Any unsaved changes will be lost',
      name: 'confirm_exit_message',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave? Your review will be discarded`
  String get confirm_leave_review {
    return Intl.message(
      'Are you sure you want to leave? Your review will be discarded',
      name: 'confirm_leave_review',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this item?`
  String get confirm_remove_item {
    return Intl.message(
      'Are you sure you want to remove this item?',
      name: 'confirm_remove_item',
      desc: '',
      args: [],
    );
  }

  /// `Login Required`
  String get login_required {
    return Intl.message(
      'Login Required',
      name: 'login_required',
      desc: '',
      args: [],
    );
  }

  /// `Please login to continue`
  String get login_to_continue {
    return Intl.message(
      'Please login to continue',
      name: 'login_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Please login to write a review`
  String get login_to_review {
    return Intl.message(
      'Please login to write a review',
      name: 'login_to_review',
      desc: '',
      args: [],
    );
  }

  /// `Please login to checkout`
  String get login_to_checkout {
    return Intl.message(
      'Please login to checkout',
      name: 'login_to_checkout',
      desc: '',
      args: [],
    );
  }

  /// `Please login to access favorites`
  String get login_to_favorites {
    return Intl.message(
      'Please login to access favorites',
      name: 'login_to_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Please login to view your orders`
  String get login_to_orders {
    return Intl.message(
      'Please login to view your orders',
      name: 'login_to_orders',
      desc: '',
      args: [],
    );
  }

  /// `Search for food, restaurants...`
  String get search_hint {
    return Intl.message(
      'Search for food, restaurants...',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Tell us about your experience...`
  String get review_hint {
    return Intl.message(
      'Tell us about your experience...',
      name: 'review_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your full name`
  String get name_hint {
    return Intl.message(
      'Enter your full name',
      name: 'name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get email_hint {
    return Intl.message(
      'Enter your email address',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get phone_hint {
    return Intl.message(
      'Enter your phone number',
      name: 'phone_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get password_hint {
    return Intl.message(
      'Enter your password',
      name: 'password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your password`
  String get confirm_password_hint {
    return Intl.message(
      'Confirm your password',
      name: 'confirm_password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your delivery address`
  String get address_hint {
    return Intl.message(
      'Enter your delivery address',
      name: 'address_hint',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Average Rating`
  String get average_rating {
    return Intl.message(
      'Average Rating',
      name: 'average_rating',
      desc: '',
      args: [],
    );
  }

  /// `{count} Reviews`
  String reviews_count(Object count) {
    return Intl.message(
      '$count Reviews',
      name: 'reviews_count',
      desc: '',
      args: [count],
    );
  }

  /// `No ratings`
  String get no_ratings {
    return Intl.message(
      'No ratings',
      name: 'no_ratings',
      desc: '',
      args: [],
    );
  }

  /// `Order Summary`
  String get order_summary {
    return Intl.message(
      'Order Summary',
      name: 'order_summary',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Fee`
  String get delivery_fee {
    return Intl.message(
      'Delivery Fee',
      name: 'delivery_fee',
      desc: '',
      args: [],
    );
  }

  /// `Select Payment Method`
  String get select_payment_method {
    return Intl.message(
      'Select Payment Method',
      name: 'select_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Cash on Delivery`
  String get cash_on_delivery {
    return Intl.message(
      'Cash on Delivery',
      name: 'cash_on_delivery',
      desc: '',
      args: [],
    );
  }

  /// `Pay when your order is delivered`
  String get cash_on_delivery_subtitle {
    return Intl.message(
      'Pay when your order is delivered',
      name: 'cash_on_delivery_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Credit / Debit Card`
  String get credit_card {
    return Intl.message(
      'Credit / Debit Card',
      name: 'credit_card',
      desc: '',
      args: [],
    );
  }

  /// `Pay now with your card`
  String get credit_card_subtitle {
    return Intl.message(
      'Pay now with your card',
      name: 'credit_card_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `InstaPay`
  String get instapay {
    return Intl.message(
      'InstaPay',
      name: 'instapay',
      desc: '',
      args: [],
    );
  }

  /// `Transfer to our InstaPay account`
  String get instapay_subtitle {
    return Intl.message(
      'Transfer to our InstaPay account',
      name: 'instapay_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `InstaPay Details`
  String get instapay_details {
    return Intl.message(
      'InstaPay Details',
      name: 'instapay_details',
      desc: '',
      args: [],
    );
  }

  /// `1. Open your Instapay app`
  String get instapay_step1 {
    return Intl.message(
      '1. Open your Instapay app',
      name: 'instapay_step1',
      desc: '',
      args: [],
    );
  }

  /// `2. Send payment to:`
  String get instapay_step2 {
    return Intl.message(
      '2. Send payment to:',
      name: 'instapay_step2',
      desc: '',
      args: [],
    );
  }

  /// `3. Enter the amount:`
  String get instapay_step3 {
    return Intl.message(
      '3. Enter the amount:',
      name: 'instapay_step3',
      desc: '',
      args: [],
    );
  }

  /// `4. Complete the transfer and enter the reference number below`
  String get instapay_step4 {
    return Intl.message(
      '4. Complete the transfer and enter the reference number below',
      name: 'instapay_step4',
      desc: '',
      args: [],
    );
  }

  /// `Copy Phone Number`
  String get copy_phone_number {
    return Intl.message(
      'Copy Phone Number',
      name: 'copy_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Transfer Reference Number`
  String get transfer_reference {
    return Intl.message(
      'Transfer Reference Number',
      name: 'transfer_reference',
      desc: '',
      args: [],
    );
  }

  /// `Enter the reference number from your Instapay transfer`
  String get transfer_reference_hint {
    return Intl.message(
      'Enter the reference number from your Instapay transfer',
      name: 'transfer_reference_hint',
      desc: '',
      args: [],
    );
  }

  /// `Verify Payment`
  String get verify_payment {
    return Intl.message(
      'Verify Payment',
      name: 'verify_payment',
      desc: '',
      args: [],
    );
  }

  /// `Verifying payment...`
  String get verifying_payment {
    return Intl.message(
      'Verifying payment...',
      name: 'verifying_payment',
      desc: '',
      args: [],
    );
  }

  /// `Payment verified successfully!`
  String get payment_verified {
    return Intl.message(
      'Payment verified successfully!',
      name: 'payment_verified',
      desc: '',
      args: [],
    );
  }

  /// `Payment verification failed`
  String get payment_verification_failed {
    return Intl.message(
      'Payment verification failed',
      name: 'payment_verification_failed',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the transfer reference number`
  String get enter_reference_number {
    return Intl.message(
      'Please enter the transfer reference number',
      name: 'enter_reference_number',
      desc: '',
      args: [],
    );
  }

  /// `Payment successful`
  String get payment_successful {
    return Intl.message(
      'Payment successful',
      name: 'payment_successful',
      desc: '',
      args: [],
    );
  }

  /// `Payment failed`
  String get payment_failed {
    return Intl.message(
      'Payment failed',
      name: 'payment_failed',
      desc: '',
      args: [],
    );
  }

  /// `Select Delivery Address`
  String get select_delivery_address {
    return Intl.message(
      'Select Delivery Address',
      name: 'select_delivery_address',
      desc: '',
      args: [],
    );
  }

  /// `Please select a delivery address`
  String get select_address_error {
    return Intl.message(
      'Please select a delivery address',
      name: 'select_address_error',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Place Order`
  String get place_order {
    return Intl.message(
      'Place Order',
      name: 'place_order',
      desc: '',
      args: [],
    );
  }

  /// `Order placed successfully!`
  String get order_placed {
    return Intl.message(
      'Order placed successfully!',
      name: 'order_placed',
      desc: '',
      args: [],
    );
  }

  /// `Error placing order`
  String get order_error {
    return Intl.message(
      'Error placing order',
      name: 'order_error',
      desc: '',
      args: [],
    );
  }

  /// `{count} Items`
  String cart_items_count(Object count) {
    return Intl.message(
      '$count Items',
      name: 'cart_items_count',
      desc: '',
      args: [count],
    );
  }

  /// `Items`
  String get items {
    return Intl.message(
      'Items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get total_amount {
    return Intl.message(
      'Total Amount',
      name: 'total_amount',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout {
    return Intl.message(
      'Checkout',
      name: 'checkout',
      desc: '',
      args: [],
    );
  }

  /// `Restaurants`
  String get admin_restaurants {
    return Intl.message(
      'Restaurants',
      name: 'admin_restaurants',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get admin_items {
    return Intl.message(
      'Items',
      name: 'admin_items',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get admin_categories {
    return Intl.message(
      'Categories',
      name: 'admin_categories',
      desc: '',
      args: [],
    );
  }

  /// `All Orders`
  String get admin_orders {
    return Intl.message(
      'All Orders',
      name: 'admin_orders',
      desc: '',
      args: [],
    );
  }

  /// `Add New Restaurant`
  String get add_new_restaurant {
    return Intl.message(
      'Add New Restaurant',
      name: 'add_new_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Add New Item`
  String get add_new_item {
    return Intl.message(
      'Add New Item',
      name: 'add_new_item',
      desc: '',
      args: [],
    );
  }

  /// `Add New Category`
  String get add_new_category {
    return Intl.message(
      'Add New Category',
      name: 'add_new_category',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Name`
  String get admin_restaurant_name {
    return Intl.message(
      'Restaurant Name',
      name: 'admin_restaurant_name',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Name (Arabic)`
  String get admin_restaurant_name_ar {
    return Intl.message(
      'Restaurant Name (Arabic)',
      name: 'admin_restaurant_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Description`
  String get admin_restaurant_description {
    return Intl.message(
      'Restaurant Description',
      name: 'admin_restaurant_description',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Description (Arabic)`
  String get admin_restaurant_description_ar {
    return Intl.message(
      'Restaurant Description (Arabic)',
      name: 'admin_restaurant_description_ar',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Address`
  String get admin_restaurant_address {
    return Intl.message(
      'Restaurant Address',
      name: 'admin_restaurant_address',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Address (Arabic)`
  String get admin_restaurant_address_ar {
    return Intl.message(
      'Restaurant Address (Arabic)',
      name: 'admin_restaurant_address_ar',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Phone`
  String get admin_restaurant_phone {
    return Intl.message(
      'Restaurant Phone',
      name: 'admin_restaurant_phone',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Fee`
  String get admin_restaurant_delivery_fee {
    return Intl.message(
      'Delivery Fee',
      name: 'admin_restaurant_delivery_fee',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Time`
  String get admin_restaurant_delivery_time {
    return Intl.message(
      'Delivery Time',
      name: 'admin_restaurant_delivery_time',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Order`
  String get admin_restaurant_min_order {
    return Intl.message(
      'Minimum Order',
      name: 'admin_restaurant_min_order',
      desc: '',
      args: [],
    );
  }

  /// `Categories (comma separated)`
  String get admin_restaurant_categories {
    return Intl.message(
      'Categories (comma separated)',
      name: 'admin_restaurant_categories',
      desc: '',
      args: [],
    );
  }

  /// `Item Name`
  String get admin_item_name {
    return Intl.message(
      'Item Name',
      name: 'admin_item_name',
      desc: '',
      args: [],
    );
  }

  /// `Item Name (Arabic)`
  String get admin_item_name_ar {
    return Intl.message(
      'Item Name (Arabic)',
      name: 'admin_item_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Item Description`
  String get admin_item_description {
    return Intl.message(
      'Item Description',
      name: 'admin_item_description',
      desc: '',
      args: [],
    );
  }

  /// `Item Description (Arabic)`
  String get admin_item_description_ar {
    return Intl.message(
      'Item Description (Arabic)',
      name: 'admin_item_description_ar',
      desc: '',
      args: [],
    );
  }

  /// `Item Price`
  String get admin_item_price {
    return Intl.message(
      'Item Price',
      name: 'admin_item_price',
      desc: '',
      args: [],
    );
  }

  /// `Item Category`
  String get admin_item_category {
    return Intl.message(
      'Item Category',
      name: 'admin_item_category',
      desc: '',
      args: [],
    );
  }

  /// `Item Categories (comma separated)`
  String get admin_item_categories {
    return Intl.message(
      'Item Categories (comma separated)',
      name: 'admin_item_categories',
      desc: '',
      args: [],
    );
  }

  /// `Category Name`
  String get admin_category_name {
    return Intl.message(
      'Category Name',
      name: 'admin_category_name',
      desc: '',
      args: [],
    );
  }

  /// `Category Name (Arabic)`
  String get admin_category_name_ar {
    return Intl.message(
      'Category Name (Arabic)',
      name: 'admin_category_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Image URL`
  String get admin_image_url {
    return Intl.message(
      'Image URL',
      name: 'admin_image_url',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get admin_upload_image {
    return Intl.message(
      'Upload Image',
      name: 'admin_upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Special Request`
  String get special_request {
    return Intl.message(
      'Special Request',
      name: 'special_request',
      desc: '',
      args: [],
    );
  }

  /// `Add special request or comment`
  String get special_request_hint {
    return Intl.message(
      'Add special request or comment',
      name: 'special_request_hint',
      desc: '',
      args: [],
    );
  }

  /// `No favorites yet`
  String get no_favorites {
    return Intl.message(
      'No favorites yet',
      name: 'no_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Add Restaurant`
  String get add_restaurant {
    return Intl.message(
      'Add Restaurant',
      name: 'add_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all fields`
  String get please_fill_all_fields {
    return Intl.message(
      'Please fill all fields',
      name: 'please_fill_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Comma Separated`
  String get comma_separated {
    return Intl.message(
      'Comma Separated',
      name: 'comma_separated',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Select Image`
  String get select_image {
    return Intl.message(
      'Select Image',
      name: 'select_image',
      desc: '',
      args: [],
    );
  }

  /// `Image Selected`
  String get image_selected {
    return Intl.message(
      'Image Selected',
      name: 'image_selected',
      desc: '',
      args: [],
    );
  }

  /// `No Image Selected`
  String get no_image_selected {
    return Intl.message(
      'No Image Selected',
      name: 'no_image_selected',
      desc: '',
      args: [],
    );
  }

  /// `Restaurants`
  String get restaurants {
    return Intl.message(
      'Restaurants',
      name: 'restaurants',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get count {
    return Intl.message(
      'Count',
      name: 'count',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get no_data {
    return Intl.message(
      'No data available',
      name: 'no_data',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Time`
  String get delivery_time {
    return Intl.message(
      'Delivery Time',
      name: 'delivery_time',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get no_orders_found {
    return Intl.message(
      'No orders found',
      name: 'no_orders_found',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Categories`
  String get restaurant_categories {
    return Intl.message(
      'Restaurant Categories',
      name: 'restaurant_categories',
      desc: '',
      args: [],
    );
  }

  /// `Category Name (English)`
  String get category_name_english {
    return Intl.message(
      'Category Name (English)',
      name: 'category_name_english',
      desc: '',
      args: [],
    );
  }

  /// `Order status updated to {status}`
  String order_status_updated_to(Object status) {
    return Intl.message(
      'Order status updated to $status',
      name: 'order_status_updated_to',
      desc: '',
      args: [status],
    );
  }

  /// `Error updating order status: {error}`
  String error_updating_order_status(Object error) {
    return Intl.message(
      'Error updating order status: $error',
      name: 'error_updating_order_status',
      desc: '',
      args: [error],
    );
  }

  /// `Select Restaurant`
  String get select_restaurant {
    return Intl.message(
      'Select Restaurant',
      name: 'select_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Item Name`
  String get item_name {
    return Intl.message(
      'Item Name',
      name: 'item_name',
      desc: '',
      args: [],
    );
  }

  /// `Item Name (Arabic)`
  String get item_name_ar {
    return Intl.message(
      'Item Name (Arabic)',
      name: 'item_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get item_description {
    return Intl.message(
      'Description',
      name: 'item_description',
      desc: '',
      args: [],
    );
  }

  /// `Description (Arabic)`
  String get item_description_ar {
    return Intl.message(
      'Description (Arabic)',
      name: 'item_description_ar',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get item_price {
    return Intl.message(
      'Price',
      name: 'item_price',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get select_category {
    return Intl.message(
      'Select Category',
      name: 'select_category',
      desc: '',
      args: [],
    );
  }

  /// `Item added successfully`
  String get item_added_successfully {
    return Intl.message(
      'Item added successfully',
      name: 'item_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Add Item`
  String get add_item {
    return Intl.message(
      'Add Item',
      name: 'add_item',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Items`
  String get restaurant_items {
    return Intl.message(
      'Restaurant Items',
      name: 'restaurant_items',
      desc: '',
      args: [],
    );
  }

  /// `Select Restaurant for Item`
  String get select_restaurant_for_item {
    return Intl.message(
      'Select Restaurant for Item',
      name: 'select_restaurant_for_item',
      desc: '',
      args: [],
    );
  }

  /// `Select a restaurant to view items`
  String get select_restaurant_to_view_items {
    return Intl.message(
      'Select a restaurant to view items',
      name: 'select_restaurant_to_view_items',
      desc: '',
      args: [],
    );
  }

  /// `Please enter category name in English`
  String get please_enter_category_name_in_english {
    return Intl.message(
      'Please enter category name in English',
      name: 'please_enter_category_name_in_english',
      desc: '',
      args: [],
    );
  }

  /// `Please enter category name in Arabic`
  String get please_enter_category_name_in_arabic {
    return Intl.message(
      'Please enter category name in Arabic',
      name: 'please_enter_category_name_in_arabic',
      desc: '',
      args: [],
    );
  }

  /// `Category Name (Arabic)`
  String get category_name_arabic {
    return Intl.message(
      'Category Name (Arabic)',
      name: 'category_name_arabic',
      desc: '',
      args: [],
    );
  }

  /// `Existing Categories`
  String get existing_categories {
    return Intl.message(
      'Existing Categories',
      name: 'existing_categories',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get add_category {
    return Intl.message(
      'Add Category',
      name: 'add_category',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get Customer {
    return Intl.message(
      'Customer',
      name: 'Customer',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get user_id {
    return Intl.message(
      'User ID',
      name: 'user_id',
      desc: '',
      args: [],
    );
  }

  /// `Order Items`
  String get order_items {
    return Intl.message(
      'Order Items',
      name: 'order_items',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Qty`
  String get qty {
    return Intl.message(
      'Qty',
      name: 'qty',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Address`
  String get delivery_address {
    return Intl.message(
      'Delivery Address',
      name: 'delivery_address',
      desc: '',
      args: [],
    );
  }

  /// `No address provided`
  String get no_address_provided {
    return Intl.message(
      'No address provided',
      name: 'no_address_provided',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message(
      'Payment',
      name: 'payment',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Restaurant Categories' key

  /// `Menu Categories`
  String get menu_categories {
    return Intl.message(
      'Menu Categories',
      name: 'menu_categories',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Declined`
  String get transaction_declined {
    return Intl.message(
      'Transaction Declined',
      name: 'transaction_declined',
      desc: '',
      args: [],
    );
  }

  /// `Your payment could not be processed.`
  String get transaction_declined_message {
    return Intl.message(
      'Your payment could not be processed.',
      name: 'transaction_declined_message',
      desc: '',
      args: [],
    );
  }

  /// `Reason: {reason}`
  String transaction_declined_reason(Object reason) {
    return Intl.message(
      'Reason: $reason',
      name: 'transaction_declined_reason',
      desc: '',
      args: [reason],
    );
  }

  /// `Please check your card details and try again, or choose a different payment method.`
  String get check_card_details {
    return Intl.message(
      'Please check your card details and try again, or choose a different payment method.',
      name: 'check_card_details',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get try_again {
    return Intl.message(
      'Try Again',
      name: 'try_again',
      desc: '',
      args: [],
    );
  }

  /// `Retry Payment`
  String get retry_payment {
    return Intl.message(
      'Retry Payment',
      name: 'retry_payment',
      desc: '',
      args: [],
    );
  }

  /// `Payment Error`
  String get payment_error {
    return Intl.message(
      'Payment Error',
      name: 'payment_error',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while processing your payment.`
  String get payment_error_message {
    return Intl.message(
      'An error occurred while processing your payment.',
      name: 'payment_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Choose Payment Method`
  String get choose_payment_method {
    return Intl.message(
      'Choose Payment Method',
      name: 'choose_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Payment Error: Unable to process transaction`
  String get payment_processing_error {
    return Intl.message(
      'Payment Error: Unable to process transaction',
      name: 'payment_processing_error',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get about_us {
    return Intl.message(
      'About Us',
      name: 'about_us',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
