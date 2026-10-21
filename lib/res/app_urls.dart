class AppUrl {
  // Production Domain (SSL Enabled): api.abrgreensinfrastructure.co.in
  static var baseUrl = 'https://api.abrgreensinfrastructure.co.in/api/';
  static var imageBaseUrl =
      'https://api.abrgreensinfrastructure.co.in/storage/';

  // Direct Server IP Fallback (13.54.11.48):
  // static var baseUrl = 'http://13.54.11.48/api/';
  // static var imageBaseUrl = 'http://13.54.11.48/storage/';
  static var customerSignatureUpload =
      baseUrl + 'customer/application/signature';
  static var customerApplicationView = baseUrl + 'customer/application/view';
  static var customerVerifyApiEndPoint = baseUrl + 'customer/verify';
  static var registerApiEndPoint = baseUrl + 'customer/register';
  static var loginEndPoint = baseUrl + 'customer/login';
  static var customerProjects = baseUrl + 'customer/project';
  static var customerCreateApplication =
      baseUrl + 'customer/application/create';
  static var getPreferences = baseUrl + 'customer/application/get-preference';
  static var getProfile = baseUrl + 'customer/profile';
  static var updateProfile = baseUrl + 'customer/profile/update';
  static var updatePassword = baseUrl + 'customer/profile/update-password';
  static var applicationCreate = baseUrl + 'customer/application/create';
  static var uploadApplicationFiles =
      baseUrl + 'customer/application/upload-file';
  static var forgetPassword = baseUrl + 'customer/forgot-password';
  static var customerApplications =
      baseUrl + 'customer/application/get-customer-application';
  static var applicationPaymentReceipt =
      baseUrl + 'customer/application/payment-receipt';
  static var downloadPaymentReceipt =
      baseUrl + 'customer/application/download-receipt';
  static var displayImagesInGallery = baseUrl + 'customer/mobile-image-gallery';
  static var displayVideosInVideos = baseUrl + 'customer/mobile-video-gallery';
  static var receiptData = baseUrl + 'customer/reciept';
  static var fetchMobilePayment = baseUrl + 'customer/mobile-payments';
  static var openLuckyDraw = baseUrl + 'customer/open-lucky-draw';
  static var luckyDrawResults = baseUrl + 'customer/lucky-draw';
  static var luckDrawWon = baseUrl + 'customer/is-customer-won';
  static var contactDetails = baseUrl + 'customer/contact-detail';
  static var homeImages = baseUrl + 'customer/get-home-image';
  static var appSettings = baseUrl + 'customer/app-settings';
  static var about = baseUrl + 'customer/about';
  static var viewReceipt = baseUrl + 'customer/reciept/view';
  static var getReferals = baseUrl + 'customer/referral';
  static var createReferal = baseUrl + 'customer/referral/create';
  static var verifyResale = baseUrl + 'customer/resale/verify';
  static var createResale = baseUrl + 'customer/resale/create';
  static var getProjects = baseUrl + 'customer/projects';
  static var getAgents = baseUrl + 'customer/agent';
  static var createSiteVisit = baseUrl + 'customer/site-visit/create';
  static var allotmentLetterData = baseUrl + 'customer/allotment-letter/data';
  static var allotmentletter = baseUrl + 'customer/allotment-letter/download';
  static var fcmtokenPush = baseUrl + 'customer/notification/start';
}
