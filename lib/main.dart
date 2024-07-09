import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomeScreen(),
    MessageScreen(),
    CartScreen(),
    ProfilPenggunaScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginRegisterPage(isLogin: true),
        '/register': (context) => LoginRegisterPage(isLogin: false),
        '/home': (context) => HomeScreen(),
        '/savedlist': (context) => SavedListScreen(),
        '/adminmessages': (context) => AdminMessagesScreen(),
        '/cart': (context) => CartScreen(),
        '/profilpengguna': (context) => ProfilPenggunaScreen(),
        '/payment': (context) => PaymentPage(
          products: [
            DesignProduct(name: 'Logo Design', price: '500.000', quantity: 1, imageUrl: 'assets/logo.jpg'),
            DesignProduct(name: 'Banner Design', price: '300.000', quantity: 2, imageUrl: 'assets/banner.jpg'),
            DesignProduct(name: 'Packaging Design', price: '700.000', quantity: 1, imageUrl: 'assets/packaging.jpg'),
          ],
          totalAmount: 1800000, // Total keseluruhan desain
        ),
        '/': (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 2, 116, 138),
            title: Text(
              "RYANVAXEL",
              style: TextStyle(
                fontFamily: 'Poppins', // Menetapkan font family menjadi Poppins
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 251, 251, 251),
              ),
            ),
          ),
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Keranjang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imagePaths = [
    'assets/logo0.jpg',
    'assets/banner0.jpg',
    'assets/packaging1.jpg',
    'assets/poster0.jpg',
    'assets/kartunama1.jpg',
    'assets/undangan1.jpg',
    'assets/karakter1.jpg',
    'assets/game1.jpg',
  ];

  final List<String> designNames = [
    'Logo Design',
    'Banner Design',
    'Packaging Design',
    'Poster Design',
    'Business Card Design',
    'Invitation Design',
    'Character Design',
    'Game Design',
  ];

  late List<String> filteredImagePaths;
  late List<String> filteredDesignNames;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredImagePaths = imagePaths;
    filteredDesignNames = designNames;
    searchController.addListener(_filterDesigns);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterDesigns);
    searchController.dispose();
    super.dispose();
  }

  void _filterDesigns() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredImagePaths = imagePaths.where((path) {
        final index = imagePaths.indexOf(path);
        final name = designNames[index].toLowerCase();
        return name.contains(query);
      }).toList();

      filteredDesignNames = designNames.where((name) {
        return name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Cari Desain',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Popular Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Menyesuaikan jumlah kolom untuk tampilan HP
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                childAspectRatio: 0.75, // Mengatur rasio aspek item grid
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredImagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(
                          imagePath: filteredImagePaths[index],
                          designName: filteredDesignNames[index],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(
                            child: Image.asset(
                              filteredImagePaths[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        filteredDesignNames[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  final String imagePath;
  final String designName;

  const ProductScreen({Key? key, required this.imagePath, required this.designName}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.designName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$100', // Harga desain
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isSaved = !isSaved;
                        });
                        if (isSaved) {
                          Navigator.pushNamed(context, '/savedlist');
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminMessagesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Text('Tambah ke Keranjang'),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _searchController = TextEditingController();
  List<ChatItemData> chatItems = [
    ChatItemData(
      sender: 'Fatmawati',
      message: 'Apakah desain sudah selesai?',
      imageUrl: 'assets/wati.jpg',
      messages: fatmawatiMessages,
    ),
    ChatItemData(
      sender: 'Ryan',
      message: 'Bisa minta revisi untuk desain tersebut?',
      imageUrl: 'assets/ryan.jpg',
      messages: ryanMessages,
    ),
    // Tambahkan ChatItem lainnya di sini
  ];
  List<ChatItemData> filteredChatItems = [];

  @override
  void initState() {
    super.initState();
    filteredChatItems = chatItems;
    _searchController.addListener(_filterChatItems);
  }

  void _filterChatItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredChatItems = chatItems
          .where((chatItem) =>
              chatItem.sender.toLowerCase().contains(query) ||
              chatItem.message.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Cari Pesan',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredChatItems.length,
              itemBuilder: (context, index) {
                final chatItem = filteredChatItems[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConversationScreen(chatItem: chatItem),
                          ),
                        );
                      },
                      child: ChatItem(
                        sender: chatItem.sender,
                        message: chatItem.message,
                        imageUrl: chatItem.imageUrl,
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  ConversationScreen({required this.chatItem});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();

  final ChatItemData chatItem; // Memindahkan field chatItem ke sini
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messages = widget.chatItem.messages;
  }

  void _sendMessage(String message, {String imageUrl = '', String fileUrl = '', bool isUser = false}) {
    setState(() {
      _messages.add(
        Message(
          sender: 'Admin',
          message: message,
          imageUrl: imageUrl,
          fileUrl: fileUrl,
          isUser: isUser,
        ),
      );
      _messageController.clear();
    });
  }

  void _pullMessage(Message message) {
    setState(() {
      _messages.remove(message);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _sendMessage('', imageUrl: image.path);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _sendMessage('', fileUrl: result.files.single.path!);
    }
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Pilih Template Pesan'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage('Apakah desain sudah selesai?', isUser: true); // Pesan dari sisi pengguna
              },
              child: Text('Apakah desain sudah selesai?'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage('Bisa minta revisi untuk desain tersebut?', isUser: true); // Pesan dari sisi pengguna
              },
              child: Text('Bisa minta revisi untuk desain tersebut?'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage('Berapa biaya untuk desain ini?', isUser: true); // Pesan dari sisi pengguna
              },
              child: Text('Berapa biaya untuk desain ini?'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatItem.sender),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Dismissible(
                  key: Key(message.hashCode.toString()),
                  direction: message.isUser ? DismissDirection.startToEnd : DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _pullMessage(message);
                  },
                  background: Container(
                    color: message.isUser ? Colors.blue : Colors.red,
                    alignment: message.isUser ? Alignment.centerLeft : Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      message.isUser ? Icons.archive : Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ChatBubble(
                    sender: message.sender,
                    message: message.message,
                    imageUrl: message.imageUrl,
                    fileUrl: message.fileUrl,
                    isUser: message.isUser,
                    onDoubleTap: (message) { // Perbaikan: Mengubah tipe parameter
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Tarik Pesan'),
                            content: Text('Apakah Anda ingin menarik pesan ini?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _pullMessage(message);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Ya'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: _showTemplateDialog,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatItemData {
  final String sender;
  final String message;
  final String imageUrl;
  final List<Message> messages;

  ChatItemData({
    required this.sender,
    required this.message,
    required this.imageUrl,
    required this.messages,
  });
}

class ChatItem extends StatelessWidget {
  final String sender;
  final String message;
  final String imageUrl;

  const ChatItem({
    required this.sender,
    required this.message,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(sender),
      subtitle: Text(message),
    );
  }
}

class Message {
  final String sender;
  final String message;
  final String imageUrl;
  final String fileUrl;
  final bool isUser;

  Message({
    required this.sender,
    required this.message,
    required this.imageUrl,
    required this.fileUrl,
    required this.isUser,
  });
}

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String imageUrl;
  final String fileUrl;
  final bool isUser;
  final Function(Message) onDoubleTap;

  const ChatBubble({
    required this.sender,
    required this.message,
    required this.imageUrl,
    required this.fileUrl,
    required this.isUser,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        onDoubleTap(Message(
          sender: sender,
          message: message,
          imageUrl: imageUrl,
          fileUrl: fileUrl,
          isUser: isUser,
        ));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                backgroundImage: AssetImage(imageUrl.isEmpty ? 'assets/admin.jpg' : imageUrl),
              ),
              SizedBox(width: 8.0),
            ],
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isNotEmpty) Text(message),
                    if (imageUrl.isNotEmpty) Image.file(File(imageUrl), height: 150),
                    if (fileUrl.isNotEmpty) Text('File: ${fileUrl.split('/').last}'),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              SizedBox(width: 8.0),
              CircleAvatar(
                backgroundImage: AssetImage('assets/admin.jpg'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<Message> fatmawatiMessages = [
  Message(
    sender: 'Fatmawati',
    message: 'Apakah desain sudah selesai?',
    imageUrl: '',
    fileUrl: '',
    isUser: true,
  ),
  Message(
    sender: 'Admin',
    message: 'Desain hampir selesai, tinggal finalisasi.',
    imageUrl: '',
    fileUrl: '',
    isUser: false,
  ),
];

List<Message> ryanMessages = [
  Message(
    sender: 'Ryan',
    message: 'Bisa minta revisi untuk desain tersebut?',
    imageUrl: '',
    fileUrl: '',
    isUser: true,
  ),
  Message(
    sender: 'Admin',
    message: 'Tentu, silakan berikan detail revisinya.',
    imageUrl: '',
    fileUrl: '',
    isUser: false,
  ),
];

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CartItem(
                name: 'Logo Design',
                price: 500000,
                quantity: 1,
                imageUrl: 'assets/logo.jpg',
              ),
              SizedBox(height: 8.0),
              CartItem(
                name: 'Banner Design',
                price: 300000,
                quantity: 2,
                imageUrl: 'assets/banner.jpg',
              ),
              SizedBox(height: 8.0),
              CartItem(
                name: 'Packaging Design',
                price: 700000,
                quantity: 1,
                imageUrl: 'assets/packaging.jpg',
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Keseluruhan Desain:',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Rp ${_calculateTotalPrice().toString()}',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment');
                  },
                  child: Text('Check Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateTotalPrice() {
    // Assuming these are the prices and quantities of the items
    List<Map<String, dynamic>> cartItems = [
      {'price': 500000, 'quantity': 1},
      {'price': 300000, 'quantity': 2},
      {'price': 700000, 'quantity': 1},
    ];

    int totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += (item['price'] as int) * (item['quantity'] as int);
    }
    return totalPrice;
  }
}

class CartItem extends StatelessWidget {
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  const CartItem({
    Key? key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text('Rp ${price.toString()}'),
                Text('Jumlah: $quantity'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final List<DesignProduct> products;
  final double totalAmount;

  const PaymentPage({
    Key? key,
    required this.products,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _proofOfPaymentImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _proofOfPaymentImage = File(pickedFile.path);
      });
    }
  }

  void _sendToAdmin() {
    if (_proofOfPaymentImage != null) {
      // Navigate to the admin chat screen with the proof of payment image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminMessagesScreen(imageFile: _proofOfPaymentImage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pesanan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Image.asset(
                          product.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp ${product.price}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Keseluruhan Desain:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${widget.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _processPayment(context);
              },
              child: Text('Pilih Metode Pembayaran'),
            ),
            if (_proofOfPaymentImage != null)
              Column(
                children: [
                  Image.file(
                    _proofOfPaymentImage!,
                    width: 200,
                    height: 200,
                  ),
                  ElevatedButton(
                    onPressed: _sendToAdmin,
                    child: Text('Kirim Bukti Pembayaran ke Admin'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Bayar melalui Bank BSI'),
              subtitle: Text('Nomor Rekening: 7221428638'),
              onTap: () {
                Navigator.pop(context);
                _processBankPayment(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Bayar melalui Dana'),
              subtitle: Text('Nomor Dana: +62 897-8801-709'),
              onTap: () {
                Navigator.pop(context);
                _processDanaPayment(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Unggah Bukti Pembayaran'),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceSelection(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _processBankPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apakah Anda yakin ingin melakukan pembayaran melalui Bank BSI?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _processDanaPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apakah Anda yakin ingin melakukan pembayaran melalui Dana?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Ambil Gambar dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Pilih Gambar dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }
}

class AdminMessagesScreen extends StatefulWidget {
  final File? imageFile;

  const AdminMessagesScreen({Key? key, this.imageFile}) : super(key: key);

  @override
  _AdminMessagesScreenState createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  File? _proofOfPaymentImage;
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _proofOfPaymentImage = widget.imageFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _proofOfPaymentImage = File(pickedFile.path);
      });
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print('File path: ${result.files.single.path}');
      // Implement send file functionality here
    } else {
      // User canceled the picker
    }
  }

  Widget _buildAdminMessageBubble(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildUserMessageBubble(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                    ),
                    IconButton(
                      onPressed: _pickFile,
                      icon: Icon(Icons.attach_file),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              // Implement send message functionality
              setState(() {
                // Simulate sending message
                _messageController.clear();
              });
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Pertanyaan Lain:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8.0),
        _buildQuestionTile('Apakah desain sudah selesai?'),
        _buildQuestionTile('Bisa minta revisi untuk desain tersebut?'),
        _buildQuestionTile('Kapan perkiraan desain akan selesai?'),
      ],
    );
  }

  Widget _buildQuestionTile(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        leading: Icon(Icons.message),
        title: Text(question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Messages'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                _buildAdminMessageBubble('Halo, ada yang bisa saya bantu hari ini?'),
                _buildUserMessageBubble('Hai, saya punya pertanyaan tentang produk.'),
                _buildAdminMessageBubble('Tentu, apa yang ingin kamu tanyakan?'),
                _buildUserMessageBubble('Bisakah saya mendapatkan lebih banyak detail tentang proses pengiriman?'),
                _buildAdminMessageBubble('Tentu saja, izinkan saya memberikan informasi yang diperlukan.'),
                _buildAdminMessageBubble('Estimasi waktu pengiriman adalah 3-5 hari kerja.'),
                _buildAdminMessageBubble('Apakah ada hal lain yang bisa saya bantu?'),
                _buildUserMessageBubble('Tidak, terima kasih. Itu saja untuk saat ini.'),
              ],
            ),
          ),
          if (_proofOfPaymentImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.file(
                    _proofOfPaymentImage!,
                    width: 200,
                    height: 200,
                  ),
                  Text('Bukti pembayaran telah dikirim ke admin.'),
                ],
              ),
            ),
          _buildMessageInputField(),
          SizedBox(height: 16.0),
          _buildExampleQuestions(),
        ],
      ),
    );
  }
}

class DesignProduct {
  final String name;
  final String price;
  final int quantity;
  final String imageUrl;

  DesignProduct({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class ProfilPenggunaScreen extends StatefulWidget {
  @override
  _ProfilPenggunaScreenState createState() => _ProfilPenggunaScreenState();
}

class _ProfilPenggunaScreenState extends State<ProfilPenggunaScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/jipan.jpg'),
                    radius: 40,
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fanji',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfilScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8.0),
                            Text('Edit Profil', style: TextStyle(fontSize: 16.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 20, thickness: 1.0),
            ListTile(
              leading: Icon(Icons.diamond),
              title: Text('Get Inspired', style: TextStyle(fontSize: 16.0)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetInspiredScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Saved List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedListScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _isExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  title: Text('Bahasa Indonesia'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/profilpengguna');
                  },
                ),
                ListTile(
                  title: Text('English'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/profilpengguna');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginRegisterPage(isLogin: true)),
                    );
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 18.0, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Handle change profile picture action
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/jipan.jpg'), // Existing profile picture
                radius: 50,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Handle save profile action
                // Kembali ke halaman profil pengguna setelah menyimpan perubahan
                Navigator.pop(context);
              },
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}

class GetInspiredScreen extends StatefulWidget {
  @override
  _GetInspiredScreenState createState() => _GetInspiredScreenState();
}

class _GetInspiredScreenState extends State<GetInspiredScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Inspired'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          AlbumCard(
            title: 'Logo Designs',
            images: ['logo1.jpg', 'logo2.jpg', 'logo3.jpg', 'logo4.jpg', 'logo5.jpg'],
            searchText: _searchText,
          ),
          AlbumCard(
            title: 'Banner Designs',
            images: ['banner1.jpg', 'banner2.jpg', 'banner3.jpg', 'banner4.jpg', 'banner5.jpg'],
            searchText: _searchText,
          ),
          AlbumCard(
            title: 'Packaging Designs',
            images: ['pack1.jpg', 'pack2.jpg', 'pack3.jpg', 'pack4.jpg', 'pack5.jpg'],
            searchText: _searchText,
          ),
          AlbumCard(
            title: 'Poster Designs',
            images: ['poster1.jpg', 'poster2.jpg', 'poster3.jpg', 'poster4.jpg', 'poster5.jpg'],
            searchText: _searchText,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AlbumCard extends StatelessWidget {
  final String title;
  final List<String> images;
  final String searchText;

  AlbumCard({required this.title, required this.images, required this.searchText});

  @override
  Widget build(BuildContext context) {
    // Filter images based on search text
    List<String> filteredImages = images.where((image) => image.contains(searchText)).toList();

    return filteredImages.isNotEmpty
        ? Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filteredImages
                        .map((image) => Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  'assets/$image',
                                  width: 230,
                                  height: 230,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          )
        : SizedBox(); // Return empty SizedBox if no matching images found
  }
}

class SavedListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Adjust this value as needed
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: 6, // Number of items in your saved list
          itemBuilder: (context, index) {
            return SavedListItem(
              image: 'logo1.jpg', // Replace with actual image asset
              rating: 4.5,
              name: 'Product Name',
              price: 50.0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen(imagePath: 'logo1.jpg', designName: 'Product Name')), // Pass the required data to ProductScreen
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SavedListItem extends StatelessWidget {
  final String image;
  final double rating;
  final String name;
  final double price;
  final VoidCallback onTap;

  SavedListItem({
    required this.image,
    required this.rating,
    required this.name,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call onTap function when the item is tapped
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                  child: Image.asset(
                    'assets/$image',
                    height: 150,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(rating.toString(), style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // Handle favorite action
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center align the text and price
                children: [
                  SizedBox(height: 8.0),
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '\$${price.toString()}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView(
        children: [
          HistoryItem(
            date: '2023-05-20 14:30',
            image: 'logo1.jpg',
            rating: 4.5,
            name: 'Logo Design',
            price: 50.0,
          ),
          HistoryItem(
            date: '2023-05-21 13:00',
            image: 'banner1.jpg',
            rating: 4.0,
            name: 'Banner Design',
            price: 30.0,
          ),
          HistoryItem(
            date: '2023-05-22 15:00',
            image: 'poster1.jpg',
            rating: 4.5,
            name: 'Poster Design',
            price: 50.0,
          ),
          HistoryItem(
            date: '2023-05-23 15:30',
            image: 'pack1.jpg',
            rating: 4.0,
            name: 'Packaging Design',
            price: 30.0,
          ),
        ],
      ),
    );
  }
}

class HistoryItem extends StatefulWidget {
  final String date;
  final String image;
  final double rating;
  final String name;
  final double price;

  HistoryItem({
    required this.date,
    required this.image,
    required this.rating,
    required this.name,
    required this.price,
  });

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductScreen(imagePath: widget.image, designName: widget.name)),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/${widget.image}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.date),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4.0),
                        Text(widget.rating.toString()),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminMessagesScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: isSaved ? Colors.red : null),
                          onPressed: () {
                            setState(() {
                              isSaved = !isSaved;
                              if (isSaved) {
                                // Handle save action
                              } else {
                                // Handle unsave action
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      widget.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.price.toString()}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CartScreen()),
                            );
                          },
                          child: Text('Buy Again'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginRegisterPage extends StatelessWidget {
  final bool isLogin;

  const LoginRegisterPage({Key? key, required this.isLogin}) : super(key: key);

  Future<void> _authenticate(String email, String password, String fullName) async {
    try {
      final url = isLogin ? 'https://yourapi.com/login' : 'https://yourapi.com/register';
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          if (!isLogin) 'fullName': fullName,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Authentication successful, handle response as needed
      } else {
        // Authentication failed, handle error
        throw Exception(responseData['error']);
      }
    } catch (error) {
      // Handle network or other errors
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kembali'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/profilpengguna', (Route<dynamic> route) => false);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Container
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_image.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset(
                    'assets/splash.jpg', // Replace with your logo path
                    width: 150, // Adjust logo size
                  ),
                ),
                // Form
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isLogin) TextField(decoration: InputDecoration(labelText: 'Full Name')),
                        SizedBox(height: 20),
                        TextField(decoration: InputDecoration(labelText: 'Email')),
                        SizedBox(height: 20),
                        TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Call _authenticate function with the appropriate parameters
                            _authenticate('email', 'password', 'fullName');
                          },
                          child: Text(isLogin ? 'Login' : 'Register'),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            if (isLogin) {
                              Navigator.pushNamed(context, '/register');
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          child: Center(
                            child: Text(
                              isLogin ? "Belum Punya Akun? Daftar" : "Sudah Punya Akun? Masuk",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
