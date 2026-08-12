// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Think Origin';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDone => 'Done';

  @override
  String get commonBack => 'Back';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmpty => 'No data';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonClose => 'Close';

  @override
  String get commonAll => 'All';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProfile => 'Me';

  @override
  String get loginTitle => 'Think Origin';

  @override
  String get loginAccountHint => 'Username / Email';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginSlogan => 'Discover crafts · Meet makers';

  @override
  String get loginAgreeTerms =>
      'By registering you agree to the User Agreement and Privacy Policy';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginRegisterLink => 'Create account';

  @override
  String get loginNeedAccount => 'Enter username or email';

  @override
  String get loginNeedPassword => 'Enter your password';

  @override
  String get loginSuccess => 'Logged in';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get registerUsernameHint =>
      'Username (2-30, letters/digits/underscore)';

  @override
  String get registerDesc => 'Sign up with username and password';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerPasswordHint => 'Password (6-32)';

  @override
  String get registerConfirmHint => 'Confirm password';

  @override
  String get registerButton => 'Sign up & log in';

  @override
  String get registerToLogin => 'Already have an account? Log in';

  @override
  String get registerEmailHintFull => 'Email';

  @override
  String get registerSuccess => 'Welcome to Think Origin!';

  @override
  String get needValidEmail => 'Enter a valid email';

  @override
  String get usernameInvalid =>
      'Username must be 2-30 letters, digits or underscores';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordAppBar => 'Change Password';

  @override
  String get changePasswordDesc =>
      'Verify your current password, then set a new one';

  @override
  String get changePasswordOld => 'Current password';

  @override
  String get changePasswordNew => 'New password (6-32)';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordButton => 'Confirm';

  @override
  String get changePasswordNeedOld => 'Enter your current password';

  @override
  String get changePasswordMin => 'Password must be at least 6 characters';

  @override
  String get changePasswordMismatch => 'Passwords do not match';

  @override
  String get changePasswordSuccess => 'Password changed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSecurity => 'Account & Security';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageChinese => 'Chinese';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsNotBound => 'Not bound';

  @override
  String get settingsBound => 'Bound';

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get settingsSet => 'Set';

  @override
  String get settingsLoginPassword => 'Login password';

  @override
  String get settingsLoginPasswordSub => 'Set · password login available';

  @override
  String get settingsSwitchAccount => 'Switch account';

  @override
  String get settingsSwitchAccountSub => 'Log in with another account';

  @override
  String get settingsSwitchConfirmTitle => 'Switch Account';

  @override
  String get settingsSwitchConfirmDesc =>
      'Switching will log out the current account and return to the login page. Continue?';

  @override
  String get settingsSwitchAction => 'Switch';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSub => 'Interactions and system alerts';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsUserAgreement => 'User Agreement';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsUserAgreementSoon => 'User Agreement coming soon';

  @override
  String get settingsPrivacyPolicySoon => 'Privacy Policy coming soon';

  @override
  String get settingsLogoutConfirmTitle => 'Log Out';

  @override
  String get settingsLogoutConfirmDesc =>
      'You will need to log in again to view messages, appointments and membership. Log out now?';

  @override
  String get settingsLogoutAction => 'Log Out';

  @override
  String get settingsScrollHint => 'Scroll down for About and Log Out';

  @override
  String get profileTitle => 'Me';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileMyAppointments => 'My appointments';

  @override
  String get profileCardWallet => 'My Wallet';

  @override
  String get profileCardWalletDesc => 'Coupons · Member perks';

  @override
  String get profileCardOrders => 'My Orders';

  @override
  String get profileCardOrdersDesc => 'Bookings · History';

  @override
  String get profileCardSettings => 'Settings';

  @override
  String get profileCardSettingsDesc => 'Account & security · General';

  @override
  String get profileServices => 'My Services';

  @override
  String get profileMoreComingSoon => 'More services coming soon';

  @override
  String profileJoined(String year, String month) {
    return 'Think Origin · joined $month/$year';
  }

  @override
  String get profileMemberCenter => 'Membership';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileEditNickname => 'Nickname';

  @override
  String get profileEditUsername => 'Username';

  @override
  String get profileEditUsernameHint =>
      'Username can only be changed once a year; used for username + password login';

  @override
  String get profileEditBio => 'Bio';

  @override
  String get profileEditLocation => 'Location';

  @override
  String get profileEditBirthday => 'Birthday';

  @override
  String get profileEditGender => 'Gender';

  @override
  String get profileEditBioHint => 'Bio: bead craft lover, healing handmade';

  @override
  String get profileEditLocationHint => 'Enter city / region';

  @override
  String get profileEditMe => 'Me';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderSecret => 'Secret';

  @override
  String get profileEditAvatarUploading =>
      'Uploading avatar, please wait before saving';

  @override
  String get profileSaveSuccess => 'Saved';

  @override
  String get profileAvatarPickFailed => 'Failed to pick avatar';

  @override
  String get commonOk => 'OK';

  @override
  String get homeOrders => 'My Orders';

  @override
  String get homeStoreSection => 'Beads';

  @override
  String get homeStoreSectionBadge => 'Popular crafts';

  @override
  String get homeBookNow => 'Book';

  @override
  String get homeBookNowDesc => 'Nearby stores / activities';

  @override
  String get homeCheckIn => 'Check in';

  @override
  String get homeCheckInDesc => 'Check in · Start';

  @override
  String get homeMember => 'Membership';

  @override
  String get homeMemberDesc => 'Benefits · Deals';

  @override
  String get homeComingSoon => 'Coming Soon';

  @override
  String get homeComingSoonMore => 'More activities coming soon';

  @override
  String get homeActivitySection => 'Activities';

  @override
  String get homeViewAll => 'View all ›';

  @override
  String get homeNoActivities => 'No activities yet';

  @override
  String get homeWaitingConfirm => 'Pending';

  @override
  String get homeWaitingChip => 'Waiting';

  @override
  String get homeWaitingStoreConfirm => 'Waiting for store confirmation';

  @override
  String homeCode(String code) {
    return 'Code $code';
  }

  @override
  String get homeOrderExpired => 'Order expired';

  @override
  String get homeToCheckIn => 'Check in';

  @override
  String homePriceFrom(String price) {
    return 'From $price';
  }

  @override
  String homeStartedAt(String date, String time, String duration) {
    return '$date $time started$duration';
  }

  @override
  String get homeAllDaySuffix => ' · all-day pass';

  @override
  String homeHourSuffix(int hours) {
    return ' · $hours h';
  }

  @override
  String get commonLoadFailed => 'Failed to load';

  @override
  String get commonLoadFailedHint =>
      'Failed to load, please make sure the backend is running';

  @override
  String get commonFree => 'Free';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get memberCenterTitle => 'Membership';

  @override
  String get memberBenefits => 'Member Benefits';

  @override
  String get memberOpenRenew => 'Open / Renew';

  @override
  String get memberBenefitPrice => 'Member Pricing';

  @override
  String get memberBenefitPriceDesc =>
      'Member prices for bookings and in-store, save up to \$20/time';

  @override
  String get memberBenefitActivity => 'Exclusive Activities';

  @override
  String get memberBenefitActivityDesc =>
      'Member-only activities and double points';

  @override
  String get memberBenefitCoupon => 'Monthly Coupons';

  @override
  String get memberBenefitCouponDesc => 'Exclusive coupons issued monthly';

  @override
  String get memberBenefitBirthday => 'Birthday Gift';

  @override
  String get memberBenefitBirthdayDesc =>
      'One free experience in your birthday month';

  @override
  String get memberAgreementHint =>
      'See the Membership Service Agreement for benefits and rules';

  @override
  String memberCurrent(String level) {
    return 'Current: $level';
  }

  @override
  String memberLevel(String level) {
    return 'Membership · $level';
  }

  @override
  String get memberValidUntil => 'Valid until';

  @override
  String get memberStatusActive => 'Active';

  @override
  String memberRemainingDays(int days) {
    return '$days days left';
  }

  @override
  String get memberWalletTitle => 'Wallet · Coupons';

  @override
  String get memberExclusiveExperience => 'Member Exclusive Experience';

  @override
  String get memberMonthlyOnce => '1 per month ›';

  @override
  String get memberMoreCoupons => 'Get more coupons';

  @override
  String get memberClaimed => 'Claimed';

  @override
  String get memberCouponCenter => 'Coupon Center';

  @override
  String get memberClaimAll => 'Claim All';

  @override
  String get memberRecommended => 'Recommended';

  @override
  String get memberRenew => 'Renew';

  @override
  String get memberOpen => 'Open';

  @override
  String get memberUsable => 'Usable';

  @override
  String get memberNoCoupons => 'No coupons yet, visit the coupon center';

  @override
  String get memberNoCouponsAvailable => 'No coupons available';

  @override
  String get memberTabUnused => 'Unused';

  @override
  String get memberTabUsed => 'Used';

  @override
  String get memberTabExpired => 'Expired';

  @override
  String get memberNotOpened => 'Not opened';

  @override
  String get memberExpired => 'Expired';

  @override
  String memberPendingHint(int count) {
    return '$count membership application(s) pending store confirmation. Pay at the store and we will activate it for you';
  }

  @override
  String get memberPurchaseTitle => 'Membership';

  @override
  String memberPurchaseDays(int days) {
    return '$days-day validity';
  }

  @override
  String get memberPayDetails => 'Payment Details';

  @override
  String get memberOriginalPrice => 'Original price';

  @override
  String get memberDiscount => 'Limited-time discount';

  @override
  String get memberPayAmount => 'Amount due';

  @override
  String get memberOfflinePayHint =>
      'Order online, pay at store: submit the order and pay the membership fee at the store to activate';

  @override
  String get memberSubmitOrder => 'Submit Order';

  @override
  String get memberThinkAgain => 'Not now';

  @override
  String get memberAgreeTerms =>
      'By submitting you agree to the Membership Service Agreement';

  @override
  String get memberOrderSubmitted => 'Order Submitted';

  @override
  String get memberWaitingConfirm => 'Waiting for store confirmation';

  @override
  String get memberOrderSubmittedDesc =>
      'Pay the membership fee at the store and the store will activate it for you\nBenefits start after activation';

  @override
  String get storeListTitle => 'Stores';

  @override
  String get storeBookNow => 'Book Now';

  @override
  String get storeNoResults => 'No matching stores';

  @override
  String storeHourlyPerPerson(String price) {
    return 'Hourly $price/person/hour';
  }

  @override
  String get storeStepDate => 'Choose date';

  @override
  String get storeDuration => 'Duration';

  @override
  String get storeNoStartTimes => 'No start times available for this slot';

  @override
  String get storeStartOnScan =>
      'Timing starts when you scan at the store; end time is fixed';

  @override
  String get weekdayToday => 'Today';

  @override
  String get weekdayTomorrow => 'Tomorrow';

  @override
  String get storeAutoTables => 'Best combination recommended automatically';

  @override
  String get storeNoTables => 'No tables available at this store';

  @override
  String storeMemberPrefix(String price) {
    return ' · Member $price';
  }

  @override
  String get storeMemberFree => ' · Member free';

  @override
  String storeGroupPrefix(String price) {
    return ' · Group $price';
  }

  @override
  String storeAllDayPrefix(String price) {
    return ' · All-day $price/person';
  }

  @override
  String get storeSearchPlaceholder => 'Search stores';

  @override
  String get storeSearchHint => 'Search stores by name / address';

  @override
  String get storeEmpty => 'No stores yet, please add them in the admin panel';

  @override
  String get storeDetailTitle => 'Store Details';

  @override
  String get storeBookingTitle => 'Book';

  @override
  String get storeBookingTypeHourly => 'Hourly';

  @override
  String get storeBookingTypePackage => 'Package';

  @override
  String get storeBookingTypeTitle => 'Choose booking type';

  @override
  String storeStartTimeAt(String hours) {
    return 'Start time (open $hours)';
  }

  @override
  String get storeNoPackages => 'No packages configured yet';

  @override
  String get storeSelectPackage => 'Select package';

  @override
  String storePackagePerPerson(String name, String price) {
    return '$name · $price/person';
  }

  @override
  String get storeAllDay => 'All-day';

  @override
  String storeAllDayDesc(String hours) {
    return 'Unlimited time within opening hours ($hours); scan to start';
  }

  @override
  String get storeNextSelectTable => 'Next · Select table';

  @override
  String get storeMemberGroupLabel => 'Member+Group \$';

  @override
  String get storeGroupLabel => 'Group \$';

  @override
  String get storeUnitLabel => 'Unit \$';

  @override
  String storePerPerson(int count) {
    return ' / person × $count';
  }

  @override
  String storeMemberPlus(String price, int count) {
    return ' + \$$price×$count';
  }

  @override
  String storeSurchargeHint(int pct) {
    return 'Includes $pct% weekend/holiday surcharge';
  }

  @override
  String get storePeopleCount => 'Guests';

  @override
  String get storeUnitPrice => 'Unit';

  @override
  String get storeGroupPrice => 'Group';

  @override
  String get storeMemberPrice => 'Member';

  @override
  String get storeSelectTable => 'Select table';

  @override
  String get storeConfirmOrder => 'Confirm Booking';

  @override
  String storePricePerHourShort(String price) {
    return '$price/hr·person';
  }

  @override
  String get storeMinHours => 'From 1 hour';

  @override
  String storeUnitPerPerson(String price) {
    return '$price/person';
  }

  @override
  String get storeTableInRecommendation =>
      'This table is already in the recommended combination';

  @override
  String get storeKeepRecommendation =>
      'Keep the recommended combination (you can switch to another table of the same size)';

  @override
  String storeTableCapacity(int count) {
    return '$count people';
  }

  @override
  String get storeTableFull => 'Full';

  @override
  String get storeNoTableCombo =>
      'No suitable table combination for this time slot; please adjust the time or contact the store';

  @override
  String storeRecommendedTables(String names, int capacity) {
    return 'Recommended: $names · seats $capacity';
  }

  @override
  String get storeCapacityInsufficient =>
      'Not enough capacity, please reselect tables';

  @override
  String get storeLoadFailed =>
      'Failed to load, please make sure the backend service is running';

  @override
  String get appointmentMyTitle => 'My Appointments';

  @override
  String get appointmentTabAll => 'All';

  @override
  String get appointmentTabBooked => 'To check in';

  @override
  String get appointmentTabInService => 'In service';

  @override
  String get appointmentTabCompleted => 'Completed';

  @override
  String get appointmentTabPending => 'Pending';

  @override
  String get appointmentStatusBooked => 'To check in';

  @override
  String get appointmentStatusCheckedIn => 'Checked in';

  @override
  String get appointmentStatusInService => 'In service';

  @override
  String get appointmentStatusCompleted => 'Completed';

  @override
  String get appointmentStatusCancelled => 'Cancelled';

  @override
  String get appointmentStatusPending => 'Pending';

  @override
  String appointmentStatusCurrentLabel(String status) {
    return 'Current status: $status';
  }

  @override
  String get appointmentWaitingConfirm => 'Waiting for store confirmation';

  @override
  String get appointmentWaitingDesc =>
      'Your booking is submitted and can be checked in after the store confirms';

  @override
  String get appointmentCheckInCode => 'Check-in code';

  @override
  String get appointmentToCheckIn => 'Check in at store';

  @override
  String get appointmentShowCode =>
      'Show this code to the staff to start your experience';

  @override
  String get appointmentExpired => 'Order expired';

  @override
  String get appointmentExpiredDesc =>
      'Past the booking time, no longer valid for check-in';

  @override
  String get appointmentCancel => 'Cancel booking';

  @override
  String get appointmentCancelDesc =>
      'The slot will be released after cancelling. Cancel now?';

  @override
  String get appointmentCancelConfirm => 'Confirm Cancel';

  @override
  String get appointmentCancelled => 'Booking cancelled';

  @override
  String get appointmentBookingType => 'Booking type';

  @override
  String get appointmentOriginalPrice => 'Original price';

  @override
  String get appointmentCoupon => 'Coupon';

  @override
  String get appointmentPayable => 'Amount due';

  @override
  String get appointmentViewQr => 'View QR code';

  @override
  String get appointmentRemainingTime =>
      'Time remaining (starts on scan, no extension)';

  @override
  String get appointmentClockOutEnd => 'End session';

  @override
  String get appointmentShowStaff => 'Show to staff to check in';

  @override
  String get appointmentCodeLabel => 'Code';

  @override
  String get appointmentQrRefresh => 'QR code refreshes every 30 seconds';

  @override
  String appointmentValidUntilAt(String time) {
    return 'Valid until $time';
  }

  @override
  String get appointmentServiceEnd => 'Session Ended';

  @override
  String get appointmentServiceEndDesc =>
      'Your session time has been recorded. Hope to see you again!';

  @override
  String get appointmentStore => 'Store';

  @override
  String get appointmentTablePeople => 'Table / Guests';

  @override
  String get appointmentStartTime => 'Started at';

  @override
  String get appointmentEndTime => 'Ended at';

  @override
  String appointmentPayAtStore(String amount) {
    return 'Pay at store $amount';
  }

  @override
  String get appointmentPayMemberFree => 'Pay at store \$0 (member free)';

  @override
  String bookingTypeHours(int hours) {
    return '$hours h';
  }

  @override
  String bookingTypePackage(String name, int hours) {
    return '$name · $hours h';
  }

  @override
  String get bookingTypeAllDay => 'All-day';

  @override
  String get appointmentBookSuccess => 'Booking Successful';

  @override
  String get appointmentBookSubmitted => 'Booking Submitted';

  @override
  String get appointmentBookSuccessDesc =>
      'Show this code at the store to check in and pay after check-in';

  @override
  String get appointmentBookSubmittedDesc =>
      'Your booking is submitted. Show the code after the store confirms it';

  @override
  String get appointmentView => 'View booking';

  @override
  String get appointmentBackHome => 'Back to Home';

  @override
  String get appointmentDetailTitle => 'Booking Details';

  @override
  String get appointmentProgress => 'Booking progress';

  @override
  String get appointmentInfo => 'Order info';

  @override
  String get appointmentItem => 'Item';

  @override
  String get appointmentTime => 'Time';

  @override
  String get appointmentPeopleCountLabel => 'Guests';

  @override
  String get appointmentNoOnlinePay =>
      'No online payment needed. Show the code at the store and pay after check-in';

  @override
  String appointmentSurchargeLabel(int pct) {
    return 'Weekend/holiday surcharge $pct%';
  }

  @override
  String get discountMember => 'Member discount';

  @override
  String get discountGroup => 'Group discount';

  @override
  String get discountMemberGroup => 'Member/group discount';

  @override
  String get commonPackage => 'Package';

  @override
  String get activitySession => 'Activity session';

  @override
  String get activityBooking => 'Activity booking';

  @override
  String get storeBooking => 'Store booking';

  @override
  String appointmentPeople(int count) {
    return '$count people';
  }

  @override
  String get appointmentTable => 'Table';

  @override
  String get appointmentSeat => 'Seat';

  @override
  String get appointmentPayMethod => 'Payment';

  @override
  String get appointmentPayOffline => 'Pay at store after check-in';

  @override
  String get appointmentAmount => 'Amount';

  @override
  String get appointmentNote => 'Note';

  @override
  String get appointmentCodeCopied => 'Check-in code copied';

  @override
  String get appointmentCheckInScan => 'Scan to check in';

  @override
  String get appointmentDetail => 'View details';

  @override
  String get appointmentBookAgain => 'Book again';

  @override
  String get appointmentEmpty => 'No appointments yet';

  @override
  String get appointmentPendingOnly => 'No pending appointments';

  @override
  String get appointmentConfirmTitle => 'Confirm Booking';

  @override
  String get appointmentSubmit => 'Submit Booking';

  @override
  String get appointmentClockOutTitle => 'End Session';

  @override
  String get appointmentClockOutDesc =>
      'Ending will stop the timer and create a completion record. End now?';

  @override
  String get appointmentClockOutConfirm => 'Confirm End';

  @override
  String get appointmentClockOutThink => 'Not now';

  @override
  String get appointmentOrderExpired => 'Order expired';

  @override
  String get appointmentShowQr => 'Show this QR code to check in';

  @override
  String appointmentQrCode(String code) {
    return 'Code $code';
  }

  @override
  String get activityTitle => 'Activities';

  @override
  String get activityListTitle => 'Activities';

  @override
  String get activityDetailTitle => 'Activity Details';

  @override
  String get activityBook => 'Book activity';

  @override
  String activityPeople(int count) {
    return '$count people';
  }

  @override
  String get activityMemberOnly => 'Members only';

  @override
  String get activityBookable => 'Bookable';

  @override
  String get activityDescPlaceholder => 'Activity details coming soon';

  @override
  String get activityPrice => 'Price';

  @override
  String get activitySelectSession => 'Select session';

  @override
  String activityRemaining(int remain, int capacity) {
    return '$remain/$capacity left';
  }

  @override
  String get activityNoteHint => 'Note (optional), e.g. two people';

  @override
  String get activityNotBookable =>
      'Online booking not available for this activity yet';

  @override
  String get activityEmpty => 'No activities';

  @override
  String get activityCardDescPlaceholder => 'Details coming soon';

  @override
  String activityPricePerPerson(String price) {
    return '$price/person';
  }

  @override
  String get activityNoSessions => 'No bookable sessions';

  @override
  String get activityFull => 'Full';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationEmpty => 'No notifications';

  @override
  String get notificationInteract => 'Interactions';

  @override
  String get notificationSystem => 'System';

  @override
  String get notificationMarkAllRead => 'All marked as read';

  @override
  String get notificationCommunitySoon => 'Community is coming soon';

  @override
  String get notificationReelsSoon => 'Reels is coming soon';

  @override
  String get notLoggedIn => 'Please log in first';

  @override
  String get noStore => 'No stores';

  @override
  String get serverError => 'Network error, please try again later';
}
