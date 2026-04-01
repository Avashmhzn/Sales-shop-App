import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:saleup_app/services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  bool _isLoading = true;
  AnimationController? _controller;
  LottieComposition? _composition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadAnimation();
    _navigateToNextScreen();
  }

  Future<void> _loadAnimation() async {
    try {
      final lottie = AssetLottie('assets/animation/splash.json');
      final composition = await lottie.load();
      if (mounted && composition.layers.isNotEmpty) {
        setState(() {
          _composition = composition;
          _isLoading = false;
          _hasError = false;
        });
        _controller!
          ..duration = composition.duration
          ..forward();
      } else {
        throw Exception('Invalid or empty Lottie composition');
      }
    } catch (e, stackTrace) {
      print('Error loading animation: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    _controller!.addStatusListener((status) async {
      if (status == AnimationStatus.completed || _hasError) {
        if (mounted) {
          final sessionManager = SessionManager();
          final canAutoLogin = await sessionManager.shouldAutoLogin();

          if (mounted) {
            if (canAutoLogin) {
              // Navigate to Home or Company Selection depending on logic
              // For now, assuming home or select_company is the entry after login
              context.go('/select_company');
            } else {
              context.go('/onboarding');
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.expand(
              child: _buildContent(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _composition == null) {
      return _buildErrorWidget();
    }

    return _buildLottieAnimation();
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLottieAnimation() {
    if (_composition == null || _composition!.layers.isEmpty) {
      return _buildErrorWidget();
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: RenderErrorBoundary(
        onError: () {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
              _controller?.stop();
            });
          }
        },
        child: SizedBox(
          width: _composition!.bounds.width.toDouble(),
          height: _composition!.bounds.height.toDouble(),
          child: Lottie(
            composition: _composition,
            controller: _controller,
            fit: BoxFit.cover,
            repeat: false,
            animate: true,
            options: LottieOptions(
              enableMergePaths: true,
              enableApplyingOpacityToLayers: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 80,
        ),
        const SizedBox(height: 16),
        const Text(
          'Failed to load animation',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please check your animation file',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 0.0,
            maxWidth: 392.7,
            minHeight: 0.0,
            maxHeight: 821.8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _controller?.reset();
                  _loadAnimation();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    context.go('/onboarding'); // ← skip also goes to onboarding
                  }
                },
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class RenderErrorBoundary extends SingleChildRenderObjectWidget {
  final VoidCallback onError;

  const RenderErrorBoundary({
    super.key,
    required this.onError,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderErrorBoundaryObject(onError: onError);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as RenderErrorBoundaryObject).onError = onError;
  }
}

class RenderErrorBoundaryObject extends RenderProxyBox {
  VoidCallback onError;

  RenderErrorBoundaryObject({required this.onError});

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      super.paint(context, offset);
    } catch (e, stackTrace) {
      print('Render error: $e');
      print('Stack trace: $stackTrace');
      onError();
    }
  }
}
