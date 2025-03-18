import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  String _statusMessage = '未ログイン';
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;
      _statusMessage = _currentUser != null 
          ? 'ログイン中: ${_currentUser!.email}' 
          : '未ログイン';
    });
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _statusMessage = 'メールアドレスとパスワードを入力してください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '登録中...';
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // ユーザープロフィール更新
      if (_displayNameController.text.isNotEmpty) {
        await userCredential.user?.updateDisplayName(_displayNameController.text);
      }
      
      await _checkCurrentUser();
      setState(() {
        _statusMessage = 'ユーザー登録成功: ${userCredential.user?.email}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = '登録エラー: ${e.code} - ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '予期せぬエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _statusMessage = 'メールアドレスとパスワードを入力してください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'ログイン中...';
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      await _checkCurrentUser();
      setState(() {
        _statusMessage = 'ログイン成功: ${userCredential.user?.email}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'ログインエラー: ${e.code} - ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '予期せぬエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'ログアウト中...';
    });

    try {
      await _auth.signOut();
      await _checkCurrentUser();
      setState(() {
        _statusMessage = 'ログアウト成功';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'ログアウトエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('認証機能テスト'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ステータス表示
            Container(
              padding: const EdgeInsets.all(8.0),
              color: _currentUser != null ? Colors.green.shade100 : Colors.orange.shade100,
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentUser != null ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 入力フォーム
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                hintText: 'example@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                hintText: '6文字以上',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '表示名（登録時のみ使用）',
                hintText: 'ニックネーム',
              ),
            ),
            const SizedBox(height: 20),
            
            // ボタン
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('新規登録'),
                  ),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('ログイン'),
                  ),
                  ElevatedButton(
                    onPressed: _currentUser != null ? _signOut : null,
                    child: const Text('ログアウト'),
                  ),
                ],
              ),
            
            const SizedBox(height: 30),
            
            // 現在のユーザー情報
            if (_currentUser != null) ...[
              const Text(
                'ユーザー情報:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('UID: ${_currentUser!.uid}'),
              Text('メール: ${_currentUser!.email}'),
              Text('表示名: ${_currentUser!.displayName ?? "未設定"}'),
              Text('メール確認済み: ${_currentUser!.emailVerified}'),
            ],
          ],
        ),
      ),
    );
  }
} 