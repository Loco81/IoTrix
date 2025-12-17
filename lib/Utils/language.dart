// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';




class Language {
  final TextEditingController APPNAME = TextEditingController(text: '');
  String VERSION = 'v1.0.1';
  late TextDirection direction;
  late String FONTFAMILY_SUBJECT;
  late String FONTFAMILY_DESCRIPTION;
  late String APPEARANCE;
  late String THEME;
  late String COLOR;
  late String LANGUAGE;
  late String SYSTEM;
  late String MANUAL;
  late String ABOUT;
  late String ABOUT_SUBJECT;
  late String ABOUT_DESCRIPTION;
  late String DONE;
  late String ERROR;
  late String NOTICE;
  late String WARNING;
  late String OK;
  late String YES;
  late String NO;
  late String PICK_COLOR;
  late String PICK_COLOR_OK;
  late String SOON;
  late String FORGOT_PIN;
  late String IMPORT_ERROR;
  late String ADD_ITEM;
  late String IMPORT_ITEM;
  late String ITEMS;
  late String RECEIVERS;
  late String SECURITY;
  late String LOGIN_PIN;
  late String EDIT_ITEM_ONLINE;
  late String EDIT_ITEM_OFFLINE;
  late String PENDING_ITEM;
  late String EDIT_RECEIVER_ONLINE;
  late String EDIT_RECEIVER_OFFLINE;
  late String RUNNING_RECEIVER;
  late String FIRST_WAY;
  late String SECONT_WAY;
  late String THIRD_WAY;
  late String SCAN;
  late String SELECT_FILE;
  late String SELECT;
  late String PASTE_LINK;
  late String LINK_ERROR;
  late String LINK;
  late String PERMISSION_ERROR;
  late String PERMISSION_ERROR2;
  late String ITEM_NAME;
  late String ITEM_URL;
  late String ITEM_PORT;
  late String ITEM_USERNAME;
  late String ITEM_PASSWORD;
  late String ITEM_TOPIC;
  late String ITEM_MESSAGE;
  late String ITEM_IP;
  late String ITEM_NAME_HINT;
  String ITEM_URL_HINT = 'example.com';
  String ITEM_PORT_HINT = '1234';
  String ITEM_LOCAL_PORT_HINT = '8181';
  String RECEIVER_LOCAL_PORT_HINT = '8182';
  String ITEM_USERNAME_HINT = 'Loco';
  String ITEM_PASSWORD_HINT = 'abcd1234';
  String ITEM_TOPIC_HINT = 'home/room';
  String ITEM_MESSAGE_HINT = 'toggle';
  late String QUICK_TILE;
  late String NONE;
  late String CHANGE;
  late String ONLINE;
  late String OFFLINE;
  late String ITEM_URL_HELP;
  late String ITEM_LOCAL_HELP;
  late String SEARCH_NETWORK;
  late String ADD_RECEIVER;
  late String RECEIVER_LOCAL_HELP;
  late String NETWORK_ERROR;
  late String VPN_ERROR;
  late String IP_AUTO;
  late String SHARE;
  late String RECOVERY_QUESTION;
  late String WRITE_QUESTION;
  late String QUESTION_HINT;
  late String WRITE_ANSWER;
  late String ANSWER;
  late String QUICK_TILE_MANAGER;
  late String EMPTY;
  late String QUICK_TILE_HELP;
  late String TILE;
  late String NO_TILE;
  late String MQTT_ERROR;
  late String MQTT_RECEIVE_ERROR;
  late String FOUND_ITEMS;
  late String CLICK_ON_ITEM;
  late String GUIDE;
  late String LOGS;
  late String GUIDE_TEXT1;
  late String GUIDE_TEXT2;
  late String GUIDE_TEXT3;
  late String GUIDE_TEXT4;
  late String GUIDE_TEXT5;
  late String MAIL_SUB;
  late String MAIL_BOD;
  late String SC_PAGES;
  late String SC_PAGES_DES;
  late String SC_ADD_BUTTON;
  late String SC_ADD_BUTTON_DES;
  late String SC_ADD_ITEM;
  late String SC_ADD_ITEM_DES;
  late String SC_ITEM;
  late String SC_ITEM_DES;
  late String SC_RECEIVER;
  late String SC_RECEIVER_DES;
  late String SC_HELP_BUTTON;
  late String SC_HELP_BUTTON_DES;

  void setLanguage(lang) {
    if(lang=='English') {
      APPNAME.text = 'IoTrix';
      direction = TextDirection.ltr;
      FONTFAMILY_SUBJECT = 'Audiowide';
      FONTFAMILY_DESCRIPTION = 'AveriaLibre';
      APPEARANCE = 'Appearance';
      THEME = 'Theme mode:';
      COLOR = 'Theme color:';
      LANGUAGE = 'Language:';
      SYSTEM = 'System';
      MANUAL = 'Manual';
      ABOUT = 'About';
      ABOUT_SUBJECT = '© 2025 IoTrix by LoCo';
      ABOUT_DESCRIPTION = 'IoTrix is a smart application designed for IoT and communication with your smart devices!😉 What makes IoTrix unique is its ability to detect and control your smart objects (such as lamps, garage doors, etc.) through notification panel tiles, Android events, voice assistants, home-screen shortcuts, your phone’s side buttons, and more!😀 The app supports both online and offline/local network communication, includes smart transmitters and receivers, and even allows you to share your items with other IoTrix users.👍 A complete guide for smart-enabling your devices and connecting them to IoTrix is built right into the app. Simply by installing IoTrix, you gain access to comprehensive information about IoT and smart device integration.❤️\n\nDo you have any questions or suggestions? Share them with me:';
      DONE = 'Done';
      ERROR = 'Error';
      NOTICE = 'Notice';
      WARNING = 'Warning';
      OK = 'Ok';
      YES = 'Yes';
      NO = 'No';
      PICK_COLOR = 'Pick a color';
      PICK_COLOR_OK = 'Ok';
      SOON = 'Coming soon';
      FORGOT_PIN = 'Forgot your PIN?';
      IMPORT_ERROR = 'The item cannot be imported! It may be damaged';
      ADD_ITEM = 'Add Item';
      IMPORT_ITEM = 'Import Item';
      ITEMS = 'Items';
      RECEIVERS = 'Receivers';
      SECURITY = 'Security';
      LOGIN_PIN = 'Login PIN';
      EDIT_ITEM_ONLINE = 'Edit the item and fill the data in the online(MQTT) section';
      EDIT_ITEM_OFFLINE = 'Edit the item and fill the data in the offline(Local) section';
      PENDING_ITEM = 'Item is pending, please wait for it to complete';
      EDIT_RECEIVER_ONLINE = 'Edit the receiver and fill the data in the online(MQTT) section';
      EDIT_RECEIVER_OFFLINE = 'Edit the receiver and fill the data in the offline(Local) section';
      RUNNING_RECEIVER = 'Receiver is running, stop it and try again';
      FIRST_WAY = 'First Way:   ';
      SECONT_WAY = 'Second Way:   ';
      THIRD_WAY = 'Third Way:   ';
      SCAN = 'Scan IoTrix item qr code';
      SELECT_FILE = 'Select IoTrix item file';
      SELECT = 'Select';
      PASTE_LINK = 'Paste IoTrix item link';
      LINK_ERROR = 'The item cannot be imported! The link is invalid';
      LINK = 'Link';
      PERMISSION_ERROR = 'Please allow permission to scan qr code';
      PERMISSION_ERROR2 = 'Please go to IoTrix app info, and in permissions section, allow camera permission to scan qr code';
      ITEM_NAME = 'Item Name';
      ITEM_NAME_HINT = 'Lamp';
      ITEM_URL = 'Broker Url';
      ITEM_PORT = 'Port';
      ITEM_USERNAME = 'Username';
      ITEM_PASSWORD = 'Password';
      ITEM_TOPIC = 'Topic';
      ITEM_MESSAGE = 'Message';
      ITEM_IP = 'IP';
      QUICK_TILE = 'Quick Tile';
      NONE = 'None';
      CHANGE = 'Change';
      ONLINE = 'Online(MQTT)';
      OFFLINE = 'Offline(Local)';
      ITEM_URL_HELP = 'If your broker has SSL, choose "SSL" for your url. Otherwise, choose "TCP" for your url';
      ITEM_LOCAL_HELP = 'Enter the IP and port of your receiver module manually, or fill the port field and press the search button to find your receiver on the network. Remember that both your phone and receiver must be connected to the same network and disable any VPN';
      SEARCH_NETWORK = 'Search the Network';
      ADD_RECEIVER = 'Add Receiver';
      RECEIVER_LOCAL_HELP = 'Enter the port manually. Make sure you are connected to a local Wi-Fi network and disable any VPN';
      NETWORK_ERROR = 'Connect to a Wi-Fi network first';
      VPN_ERROR = 'Disable your VPN';
      IP_AUTO = 'IP (auto)';
      SHARE = 'Share';
      RECOVERY_QUESTION = 'Recovery Question';
      WRITE_QUESTION = 'Write a question';
      QUESTION_HINT = 'What is the name of your first school?';
      WRITE_ANSWER = 'Write the answer';
      ANSWER = 'Answer';
      QUICK_TILE_MANAGER = 'Quick Tile Manager';
      EMPTY = 'Empty';
      QUICK_TILE_HELP = 'You can set your item to one of the 6 IoTrix tiles in the Notifications  Tiles Manager. After that, you can launch your item by clicking on the item tile in the Notifications Panel (Control Center). Remember to add all 6 IoTrix tiles to the Notifications Panel Tiles Manager first (click on the pencil icon or the edit button, then add the IoTrix tiles and save it)';
      TILE = 'Tile';
      NO_TILE = 'No Tile';
      MQTT_ERROR = 'Failed to send MQTT message! Make sure you entered the server address, port, and other information correctly';
      MQTT_RECEIVE_ERROR = 'Failed to start receiving MQTT message! Make sure you entered the server address, port, and other information correctly';
      FOUND_ITEMS = 'Found items';
      CLICK_ON_ITEM = 'Select the item you want to connect to';
      GUIDE = 'Guide';
      LOGS = 'Logs';
      GUIDE_TEXT1 = 'This app is designed for smart automation of your home, workplace, and more, with its main purpose being the Internet of Things. Depending on your needs, you can control your devices with IoTrix either online through the internet or offline over your local network without internet access.\n\nSome features of IoTrix:\n\n● Ability to connect to smart objects either online or offline over the local network\n● Ability to add a smart transmitter or receiver to the app\n● Option to assign your item to the notification panel tiles for easier access\n● Your item can be recognized by Android events and voice assistants\n● Ability to share your item or add an item using a qr code, file, or link\n\nThe app works using modules that support internet or network connectivity, such as the NodeMCU ESP8266, which acts as a bridge between the app and your devices—for example, your room’s light. In this section, through a complete example, you will see how to smart-enable a lamp or any other device.';
      GUIDE_TEXT2 = 'First, register on an MQTT Broker website so we can connect the app and the module to the server. I recommend the "Crystalmq Bevywise" website, which is free to use. Then, write down the URL, port, username, and password that the website provides, as we will need them later.\n\nItems you need to prepare:\n\n - NodeMCU ESP8266 module\n - Relay module (e.g., 4-channel)\n - 5V adapter (at least 2A)\n - Conversion switch for the lamp\n - Small switch to turn the modules’ power on/off\n - 6 jump wires (for module connections)\n - Wires for power transfer\n\nThe NodeMCU module’s job is to communicate with the app through the website’s server or the local network and send commands to the relay module. The relay module’s job is to turn the electrical current on and off.\nFirst, install the Arduino IDE on your computer so that we can write code on the NodeMCU module. Run the program, go to Preferences, and add the link below to the Additional Boards Manager URLs, then wait for it to download:';
      GUIDE_TEXT3 = 'In the Boards Manager, install the ESP8266 package, and in the Library Manager, install the PubSubClient package (by Nick O\'Leary).\nFrom Tools > Boards > ESP8266, select NodeMCU 0.9.\nConnect the NodeMCU module to your computer and select the board’s port from the top of the Arduino window (usually COM8).\nFinally, in the Tools menu, set the upload speed to 115200.\n\nEverything is ready!\nNow copy the code below, paste it into the Arduino IDE, and press the Upload button at the top of the window so the code will be uploaded to the module (wait until the upload completes and the module resets):';
      GUIDE_TEXT4 = 'Remember to replace the Wi-Fi name and password variables with your own Wi-Fi modem information. Also, replace the broker server address, port, username, and password from the server website (the ones you wrote down earlier) with the corresponding variables in the code. (You must set the value of the topic variable yourself.)\n\nNow, following the diagram below, set up the modules and components you have prepared:';
      GUIDE_TEXT5 = 'We connected the K1 output of the relay module to the lamp’s wall switch. The remaining outputs (K2 to K4) are left unused, and you can connect anything you want to them if you need to turn its power on or off.\nRemember that only the D1, D2, D5, D6, and D7 pins of the NodeMCU are useful for our purpose, and you may connect them to the relay inputs.\nThe L1 and L2 outputs must be connected to the wall switch inputs, and the output of the switch should be connected to the lamp.\nUsing a physical wall switch ensures that the lamp can be controlled independently from the module, allowing both the switch and the module to change the lamp’s state.\n\nYour setup is complete!\nNow, in IoTrix, go to the Items section and add a new item. Enter your desired name and icon. If you want the item (lamp) to be controllable through the control center tile (notification bar), assign a Tile to the item as well.\nEnter the Broker server information you noted earlier.\nIn the message field, based on the code we uploaded to the module, you can send commands in two formats:\n\npin/toggle\npin/press/ms\n\nReplace pin with the NodeMCU pin name you want to control.\nIn the first example, the pin switches to the opposite state regardless of its current state, which is the best option for lamp control.\nIn the second example, replace ms with the duration in milliseconds. In this mode, the selected pin will be activated for the specified duration and then deactivated again (useful for pressing a remote button or similar actions). For example:\n\nd1/toggle\nTurns the lamp on or off (we connected the relay input for the lamp to D1).\n\nd2/press/400\nActivates pin D2 for 400 milliseconds and then deactivates it.\n\nAdd the item. Now, by tapping the item, the MQTT command is sent to the server, received by the module, and your lamp turns on or off!\n\nTo switch the item’s communication mode from online to offline/local network, hold your finger on the item.\nYou must have entered the module’s IP address in the item details (you can scan the network to find the module).\n\n\nThe app also has a Receivers section. If you add a receiver, it behaves similarly to your module and listens to incoming messages, displaying them.\nThis is useful for testing the system you’ve built or monitoring the state changes of your devices, such as the lamp.';
      MAIL_SUB = 'Hi LoCo';
      MAIL_BOD = 'I emailed you to tell you that...';
      SC_PAGES = 'Pages';
      SC_PAGES_DES = 'Welcome to IoTrix! Please read the instructional texts carefully to become familiar with how to use the app.\nThe app has two main sections: Items and Receivers. If you want to send messages to your smart device and communicate with it, you need to add a new Item. If you want to receive messages just like a smart device, or if you want to test the behavior of your transmitter, you need to add a Receiver.';
      SC_ADD_BUTTON = 'Add an Item';
      SC_ADD_BUTTON_DES = 'Use this section to add an item. You can manually enter the information of your smart device or your Broker server, or you can import an IoTrix item into your items list using its qr code, file, or link. To add a Receiver, first go to the Receivers page and press the same add button there.';
      SC_ADD_ITEM = 'Item Info';
      SC_ADD_ITEM_DES = 'Enter the Broker server information for online communication, or the IP information for offline/local network communication with your smart device. If your Broker server does not support SSL, use TCP mode. Make sure to write the Topic exactly the same as the Topic you used in the receiver code of your smart devices. By pressing the Change button in the Quick Tile section, you can assign one of the six IoTrix tiles in your notification panel’s quick tiles to this item, so the item can be activated by tapping the tile. Be sure to first go to the quick settings tile manager and add all six IoTrix tiles to your notification panel.';
      SC_ITEM = 'Item Function';
      SC_ITEM_DES = 'Your item has been successfully added! If you have entered the server information correctly, you can press the item to send the command to the server and activate it! To switch the item to offline/local network mode, hold your finger on the item. If you assigned a notification panel tile to your item, you can now activate the item through the tile as well. A cool feature is that if you hold your finger on IoTrix in your phone’s app list, you will see your item there! This means you can activate the item without opening IoTrix, create a shortcut on your home screen, and even have your item recognized by voice assistants like Google Assistant or Bixby, as well as your phone’s Modes and Routines! This means you can introduce your item to your voice assistant and control it with your voice! Or, if your phone (like Samsung) supports Routines, you can control your item using the side buttons, your S-Pen, and much more!';
      SC_RECEIVER = 'Receiver Function';
      SC_RECEIVER_DES = 'Your receiver has been successfully added! If you have entered the server information correctly, you can press the receiver to enable or disable it. To switch the receiver to offline/local network mode, hold your finger on it. When the receiver is enabled, it will receive and display any incoming messages—whether over the network or online. For example, if you configure your receiver with the same settings as your smart lamp, the receiver will behave exactly like your lamp. Whenever a message or command is sent to your lamp, the receiver will notify you and display the message content.';
      SC_HELP_BUTTON = 'More Help';
      SC_HELP_BUTTON_DES = 'If you need further guidance, you can use this section.';
    }
    else if(lang=='Persian') {
      APPNAME.text = 'آی‌او‌تریکس';
      direction = TextDirection.rtl;
      FONTFAMILY_SUBJECT = 'Lalezar';
      FONTFAMILY_DESCRIPTION = 'Harmattan';
      APPEARANCE = 'تنظیمات ظاهری';
      THEME = 'حالت پوسته:';
      COLOR = 'رنگ پوسته:';
      LANGUAGE = 'زبان برنامه:';
      SYSTEM = 'سیستم';
      MANUAL = 'دستی';
      ABOUT = 'درباره';
      ABOUT_SUBJECT = '© 2025 IoTrix by LoCo';
      ABOUT_DESCRIPTION = 'آی‌او‌تریکس یک برنامه ی هوشمند با کاربرد اینترنت اشیا و ارتباط با وسایل هوشمند شما است!😉 چیزی که آی‌او‌تریکس را متمایز میکند، قابلیت شناسایی و کنترل اشیا هوشمند خود (مانند لامپ، درب پارکینگ و ...) از طریق کاشی پنل اعلان ها، توسط رویداد های اندروید و دستیار های صوتی، میان بر روی صفحه اصلی، دکمه های بغل گوشی خود و غیره است!😀 این برنامه هم از ارتباط آنلاین و هم آفلاین تحت شبکه پشتیبانی می‌کند، فرستنده و گیرنده هوشمند دارد، و حتی می‌توانید آیتم های خود را با دیگر کاربران آی‌او‌تریکس به اشتراک بگذارید.👍 آموزش هوشمند سازی وسایل و ارتباط آنها با آی‌او‌تریکس بصورت کامل در برنامه وجود دارد و فقط با نصب آی‌او‌تریکس، میتوانید به اطلاعات جامع هوشمند سازی و اینترنت اشیا دست یابید.❤️\n\nسوال یا پیشنهادی دارید؟ با من در میان بگذارید:';
      DONE = 'انجام شد';
      ERROR = 'خطا';
      NOTICE = 'توجه';
      WARNING = 'هشدار';
      OK = 'باشه';
      YES = 'بله';
      NO = 'خیر';
      PICK_COLOR = 'رنگ مورد نظر را انتخاب کنید';
      PICK_COLOR_OK = 'تایید';
      SOON = 'به زودی';
      FORGOT_PIN = 'پین را فراموش کرده اید؟';
      IMPORT_ERROR = 'نمی‌توان آیتم را وارد کرد! احتمالاً آسیب دیده است';
      ADD_ITEM = 'افزودن آیتم';
      IMPORT_ITEM = 'وارد کردن آیتم';
      ITEMS = 'آیتم ها';
      RECEIVERS = 'گیرنده ها';
      SECURITY = 'امنیت';
      LOGIN_PIN = 'پین ورود';
      EDIT_ITEM_ONLINE = 'آیتم را ویرایش کرده و داده های بخش آنلاین (سرور) را وارد کنید';
      EDIT_ITEM_OFFLINE = 'آیتم را ویرایش کرده و داده های بخش آفلاین (شبکه) را وارد کنید';
      PENDING_ITEM = 'آیتم در انتظار است، صبر کنید تا اتمام یابد';
      EDIT_RECEIVER_ONLINE =  'گیرنده را ویرایش کرده و داده های بخش آنلاین (سرور) را وارد کنید';
      EDIT_RECEIVER_OFFLINE = 'گیرنده را ویرایش کرده و داده های بخش آفلاین (شبکه) را وارد کنید';
      RUNNING_RECEIVER = 'گیرنده درحال اجرا است، آن را متوقف کنید و مجدد تلاش کنید';
      FIRST_WAY = 'روش اول:   ';
      SECONT_WAY = 'روش دوم:   ';
      THIRD_WAY = 'روش سوم:   ';
      SCAN = 'بارکد آیتم آی‌او‌تریکس را اسکن کنید';
      SELECT_FILE = 'فایل آیتم آی‌او‌تریکس را انتخاب کنید';
      SELECT = 'انتخاب';
      PASTE_LINK = 'لینک آیتم آی‌او‌تریکس را جای‌گذاری کنید';
      LINK_ERROR = 'نمی‌توان آیتم را وارد کرد! لینک نامعتبر است';
      LINK = 'لینک';
      PERMISSION_ERROR = 'لطفا اجازه ی دسترسی را جهت اسکن بارکد قبول کنید';
      PERMISSION_ERROR2 = 'لطفا به اطلاعات برنامه ی آی‌او‌تریکس مراجعه کرده و در بخش دسترسی ها، دسترسی دوربین جهت اسکن بارکد را مجاز کنید';
      ITEM_NAME = 'نام آیتم';
      ITEM_NAME_HINT = 'لامپ';
      ITEM_URL = 'لینک سرور';
      ITEM_PORT = 'پورت';
      ITEM_USERNAME = 'نام کاربری';
      ITEM_PASSWORD = 'رمز عبور';
      ITEM_TOPIC = 'تاپیک';
      ITEM_MESSAGE = 'پیام';
      ITEM_IP = 'آی‌پی';
      QUICK_TILE = 'کاشی پنل اعلان';
      NONE = 'خالی';
      CHANGE = 'تغییر';
      ONLINE = 'آنلاین (سرور)';
      OFFLINE = 'آفلاین (شبکه)';
      ITEM_URL_HELP = 'اگر سرور شما SSL دارد، برای آدرس اینترنتی خود "SSL" را انتخاب کنید، در غیر این صورت، برای آدرس اینترنتی خود "TCP" را انتخاب کنید';
      ITEM_LOCAL_HELP = 'آی‌پی و پورت ماژول گیرنده خود را به صورت دستی وارد کنید، یا فیلد پورت را وارد کنید و دکمه جستجو را فشار دهید تا گیرنده شما در شبکه پیدا شود. به یاد داشته باشید که هر دو گوشی و گیرنده شما باید به یک شبکه متصل باشند و هرگونه فیلترشکن را غیرفعال کنید';
      SEARCH_NETWORK = 'جستجو در شبکه';
      ADD_RECEIVER = 'افزودن گیرنده';
      RECEIVER_LOCAL_HELP = 'پورت را به صورت دستی وارد کنید. مطمئن شوید که به یک شبکه وای‌فای محلی متصل هستید و هرگونه فیلترشکن را غیرفعال کنید';
      NETWORK_ERROR = 'ابتدا به یک شبکه ی وای‌فای متصل شوید';
      VPN_ERROR = 'فیلترشکن خود را غیرفعال کنید';
      IP_AUTO = 'آی‌پی (خودکار)';
      SHARE = 'اشتراک گذاری';
      RECOVERY_QUESTION = 'سوال بازیابی';
      WRITE_QUESTION = 'یک سوال بنویسید';
      QUESTION_HINT = 'نام اولین مدرسه ی شما چیست؟';
      WRITE_ANSWER = 'پاسخ را بنویسید';
      ANSWER = 'پاسخ';
      QUICK_TILE_MANAGER = 'کاشی پنل مدیریت';
      EMPTY = 'خالی';
      QUICK_TILE_HELP = 'شما می‌توانید آیتم خود را روی یکی از 6 کاشی آی‌او‌تریکس در پنل مدیریت اعلان ها تنظیم کنید. پس از این، می‌توانید با کلیک روی کاشی آیتم در پنل اعلان (مرکز کنترل) آیتم خود را اجرا کنید. به یاد داشته باشید که ابتدا هر 6 کاشی آی‌او‌تریکس را به پنل مدیریت کاشی اعلان اضافه کنید (روی نماد مداد یا دکمه ویرایش کلیک کنید، سپس کاشی‌های آی‌او‌تریکس را اضافه کرده و آن را ذخیره کنید)';
      TILE = 'کاشی';
      NO_TILE = 'بدون کاشی';
      MQTT_ERROR = 'ارسال پیام ناموفق بود! اطمینان حاصل کنید که آدرس سرور و پورت و بقیه ی اطلاعات را صحیح وارد کرده اید';
      MQTT_RECEIVE_ERROR = 'راه اندازی گیرنده پیام ناموفق بود! اطمینان حاصل کنید که آدرس سرور و پورت و بقیه ی اطلاعات را صحیح وارد کرده اید';
      FOUND_ITEMS = 'آیتم های پیدا شده';
      CLICK_ON_ITEM = 'آیتمی که می‌خواهید به آن متصل شوید را انتخاب کنید';
      GUIDE = 'راهنما';
      LOGS = 'گزارش ها';
      GUIDE_TEXT1 = 'این برنامه جهت هوشمند سازی خانه، محل کار و ... طراحی شده است و کاربرد اصلی آن اینترنت اشیا است. بنابر نیاز خود، میتوانید بصورت آنلاین و کاملا اینترنتی یا از طریق شبکه و بدون اینترنت وسایل خود را با آی‌او‌تریکس کنترل کنید.\n\nبرخی از ویژگی های آی‌او‌تریکس:\n\n● امکان اتصال آنلاین یا آفلاین تحت شبکه با اشیا هوشمند\n● امکان افزودن فرستنده یا گیرنده هوشمند به برنامه\n● امکان تنظیم آیتم خود در بخش کاشی های پنل مدیریت اعلان برای دسترسی راحت تر\n● شناسایی شدن آیتم شما توسط رویداد های اندروید و دستیار های صوتی\n● امکان اشتراک گذاری آیتم خود یا افزودن آیتم با استفاده از بارکد، فایل یا لینک\n\nکارکرد این برنامه از طریق ماژول هایی با قابلیت اتصال اینترنت و شبکه مانند NodeMCU ESP8266 است، بطوریکه ماژول واسطه ی بین برنامه و وسایل شما مانند لامپ اتاق میشود. در این بخش با ذکر یک مثال کامل، نحوه هوشمند سازی لامپ یا ... را مشاهده میکنید.';
      GUIDE_TEXT2 = 'ابتدا در یک سایت MQTT Broker ثبت نام کنید تا برنامه و ماژول را به سایت وصل کنیم. پیشنهاد من سایت Crystalmq bevywise است و رایگان می‌باشد. سپس url، پورت، نام کاربری و رمز عبوری که سایت در اختیار شما میگذارد را یادداشت کرده تا بعدا از آنها استفاده کنیم.\n\nوسایلی که باید تهیه کنید:\n\n - ماژول NodeMCU ESP8266\n - ماژول رله (مثلا 4 کاناله)\n - آداپتور 5 ولت (حداقل 2 آمپر)\n - کلید تبدیل برای لامپ\n - کلید کوچک جهت قطع و وصل برق ماژول ها\n - 6 عدد جامپ وایر (دوسر مادگی، جهت ارتباط بین ماژول ها)\n - سیم برای انتقال برق (به اندازه ی نیاز)\n\nوظیفه ی ماژول NodeMCU ارتباط با برنامه از طریق سرور سایت یا شبکه ی محلی و ارسال فرمان به ماژول رله است و وظیفه ی ماژول رله، قطع و وصل کردن جریان برق می‌باشد. ابتدا برنامه ی Arduino را روی کامپیوتر خود نصب کرده تا روی ماژول NodeMCU کد بنویسیم. برنامه را اجرا کرده و از بخش Prefrences لینک زیر را به Additional Boards Manager اضافه کنید و صبر کنید تا دانلود شود:';
      GUIDE_TEXT3 = 'در بخش Boards Manager، پکیج ESP8266 را نصب کنید، و در بخش Library Manager پکیج PubSubClient (by Nick O\'Leary) را نصب کنید. از بخش Tools > Boards > ESP8266، آیتم NodeMCU 0.9 را انتخاب کنید. ماژول NodeMCU را به کامپیوتر خود وصل کنید و از قسمت بالای پنجره ی برنامه، پورت بورد را انتخاب کنید (معمولا COM8 می‌باشد). در نهایت در بخش Tools، سرعت آپلود را روی 115200 تنظیم کنید. همه چیز آماده است! حال کد زیر را کپی کرده و در Arduino جای‌گذاری کنید و دکمه ی آپلود را از بالای پنجره برنامه بفشارید تا کد شما روی ماژول آپلود شود (صبر کنید تا آپلود کامل شده و ماژول ریست شود):';
      GUIDE_TEXT4 = 'به یاد داشته باشید که متغیر های نام و رمز عبور وای فای را با اطلاعات مودم وای فای خود جایگذین کنید، همچنین آدرس سرور Broker، پورت، نام کاربری و رمز عبور سایت سرور را که پیش تر یادداشت کرده اید جایگذین متغیر های مربوطه در کد کنید (متغیر Topic را خودتان باید مقدار دهی کنید).\n\nحال طبق تصویر زیر،  ماژول ها و وسایلی که تهیه کرده اید را راه اندازی کنید:';
      GUIDE_TEXT5 = 'خروجی پایه ی K1 ماژول رله را به کلید تبدیل لامپ وصل کرده ایم. بقیه ی خروجی های K2 تا K4 را آزاد گذاشته ایم و میتوانید هرچیزی به آن متصل کنید که برق آن قطع یا وصل شود. به یاد داشته باشید که فقط پایه های d1، d2، d5، d6، d7 ماژول NodeMCU برای ما کاربرد دارند و میتوان از آنها استفاده کرد و به ماژول رله متصلشان کرد. خروجی های L1 و L2 باید به ورودی های کلید تبدیل لامپ وصل شوند و خروجی کلید تبدیل به لامپ وصل شود. استفاده از کلید تبدیل به این دلیل است که کلید فیزیکی لامپ مستقل از ماژول ما کار کند و هرکدام از آنها وضعیت لامپ را بتوانند تغییر دهند.\n\n\nکار تمام شده است! حال در آی‌او‌تریکس، در بخش Items، یک آیتم جدید اضافه کنید. نام و آیکون دلخواد خود را وارد کنید، اگر میخواهید از طریف کاشی کنترل سنتر (نوار اعلان) آیتم شما (لامپ) قابل کنترل باشد، یک Tile هم برای آیتم خود تنظیم کنید. اطلاعات سرور Broker که یادداشت کرده اید را وارد کنید و در بخش پیام، طبق کدی که روی ماژول نوشته ایم، به دو طریق می‌توانید پیام به ماژول ارسال کنید:\npin/toggle\npin/press/ms\nبه جای pin، نام پایه ی ماژول NodeMCU که میخواهید دستور به آن ارسال شود را وارد کنید. در مثال اول، پایه در هر حالتی که هست به حالت مخالف تغییر حالت میدهد که برای کنترل لامپ بهترین گزینه است. در مثال دوم، زمان لازم بر حسب میلی ثانیه را جایگذین ms کنید. در این حالت به اندازه ی مقدار زمانی که وارد کرده اید، پایه ی مورد نظر فعال و مجدد غیر فعال میشود (مناسب برای فشردن دکمه ی ریموت یا مشابه آن). مثلا:\nd1/toggle\nلامپ ما را خاموش یا روشن می‌کند (ورودی رله مربوط به لامپ را به d1 وصل کرده ایم). \nd2/press/400\nبه مدت 400 میلی ثانیه پایه ی d2 را فعال و سپس غیر فعال میکند.\nآیتم را اضافه کنید. حال با فشردن آیتم، دستور MQTT به سرور ارسال شده و توسط ماژول دریافت میشود و لامپ شما خاموش یا روشن میشود!\nبرای تغییر حالت ارسال پیام آیتم از آنلاین به آفلاین تحت شبکه، انگشت خود رو روی آیتم نگه دارید. اطلاعات IP ماژول را باید در اطلاعات آیتم وارد کرده باشید (میتوانید ماژول را در شبکه جستجو کنید).\n\n\nبرنامه یک بخش "گیرنده ها" هم دارد که اگر گیرنده ای به برنامه اضافه کنید، همانند ماژول شما عمل میکند و پیام هارا دریافت کرده و نمایش میدهد. جهت تست ساز و کاری که طراحی کرده اید یا مطلع شدن از تغییر حالت وسایل شما مانند لامپ مناسب است.';
      MAIL_SUB = 'سلام لوکو';
      MAIL_BOD = 'بهت ایمیل زدم تا بگم که...';
      SC_PAGES = 'صفحات';
      SC_PAGES_DES = 'به آی‌او‌تریکس خوش آمدید! لطفا با دقت متن های آموزشی را مطالعه کنید تا با نحوه ی کار با برنامه آشنا شوید.\nبرنامه دو بخش اصلی دارد: آیتم ها و گیرنده ها. اگر میخواهید به وسیله ی هوشمند خود پیام بفرستید و با آن ارتباط بگیرید، باید یک آیتم جدید اضافه کنید، اگر میخواهید مانند وسیله هوشمند پیام دریافت کنید یا عملکرد فرستنده خود را تست کنید، باید یک گیرنده اضافه کنید.';
      SC_ADD_BUTTON = 'افزودن آیتم';
      SC_ADD_BUTTON_DES = 'از این بخش برای افزودن آیتم استفاده کنید. می‌توانید اطلاعات وسیله ی هوشمند یا سرور کارگزار (Broker) خود را دستی وارد کنید، یا یک آیتم آی‌او‌تریکس را از طریق بارکد، فایل یا لینک آن به آیتم های خود وارد کنید. جهت افزودن گيرنده ابتدا به صفحه ی گیرنده ها رفته و در آنجا همین دکمه ی افزودن را بفشاريد.';
      SC_ADD_ITEM = 'اطلاعات آیتم';
      SC_ADD_ITEM_DES = 'اطلاعات مربوط به سرور Broker جهت ارتباط آنلاين یا اطلاعات آی‌پی جهت اتصال تحت شبکه و آفلاین با وسیله ی هوشمند خود را وارد کنید. اگر سرور Broker شما SSL ندارد، از حالت TCP استفاده کنید. توجه داشته باشید که Topic را دقیقا مطابق با Topic که در کد های گیرنده ی وسایل هوشمند خود نوشته اید بنویسید. با فشردن دکمه ی تغییر در بخش کاشی پنل اعلان، میتوانید یکی از 6 عدد کاشی آی‌او‌تریکس در پنل مدیریت بخش اعلان های خود را به این آیتم اختصاص دهید تا با فشردن کاشی، آیتم فعال شود. حتما ابتدا به مدیریت کاشی های پنل اعلان مراجعه کرده و همه ی 6 عدد کاشی آی‌او‌ترکیس را به کاشی ها اضافه کنید.';
      SC_ITEM = 'عملکرد آیتم';
      SC_ITEM_DES = 'آیتم شما با موفقیت اضافه شده است! اگر اطلاعات مربوط به سرور را درست وارد کرده باشید، با فشردن آیتم میتوانید دستور را به سرور بفرستید و آیتم را فعال کنید! برای تغییر حالت آیتم به آفلاین تحت شبکه، انگشت خود را روی آیتم نگه دارید. اگر یک کاشی پنل اعلان به آیتم خود اختصاص داده اید، هم اکنون از طریق کاشی هم میتوانید آیتم را فعال کنید. نکته ی جالب این است که اگر در لیست برنامه های موبایل خود روی آی‌او‌تریکس انگشت خود را نگه دارید، آیتم خود را آنجا میبینید! هم میتوانید بدون باز کردن آی‌او‌تریکس آیتم را فعال کنید، هم میتوانید میان‌بر آیتم را روی صفحه اصلی خود ایجاد کنید، و هم آیتم شما توسط دستیار های صوتی مانند Google assistant یا Bixby و توسط حالت ها و برنامه های روزانه (Modes and Routines) موبایل شما شناسایی می‌شود! این یعنی شما می‌توانید با تنظیم کردن دستیار صوتی خود، آیتم خود را به آن معرفی کنید و با صدای خود آیتم را کنترل کنید! یا اگر موبایل شما (مثل سامسونگ) قابلیت برنامه های روزانه (Routines) دارد، آیتم خود را از طریق دکمه های بغل گوشی، قلم گوشی خود و ... کنترل کنید!';
      SC_RECEIVER = 'عملکرد گیرنده';
      SC_RECEIVER_DES = 'گیرنده ی شما با موفقیت اضافه شده است! اگر اطلاعات مربوط به سرور را درست وارد کرده باشید، با فشردن گیرنده میتوانید آن را فعال یا غیرفعال کنید! برای تغییر حالت گیرنده به آفلاین تحت شبکه، انگشت خود را روی گیرنده نگه دارید. اگر گیرنده را فعال کنید، هرگونه پیام دریافتی تحت شبکه یا آنلاین را دریافت می‌کند و به شما نمایش می‌دهد.  مثلا اگر اطلاعات گیرنده ی خود را مطابق با لامپ هوشمند خود وارد کنید، گیرنده دقیقا همانند لامپ شما عمل می‌کند و اگر به لامپ شما پیام یا دستوری ارسال شود، گیرنده به شما اطلاع می‌دهد و متن پیام را به شما نمایش می‌دهد.';
      SC_HELP_BUTTON = 'راهنمایی بیشتر';
      SC_HELP_BUTTON_DES = 'اگر نیاز به راهنمایی بیشتر دارید، از این بخش می‌توانید استفاده کنید.';
    }
  }
}