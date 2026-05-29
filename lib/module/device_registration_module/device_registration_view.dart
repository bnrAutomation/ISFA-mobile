import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/device_registration_module/bloc/device_registration_bloc.dart';
import 'package:i_densfa/module/device_registration_module/device_registration_repository.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/models/device_auth_payload.dart';

class DeviceRegistrationView extends StatefulWidget {
  final String initialUsername;

  const DeviceRegistrationView({super.key, this.initialUsername = ''});

  @override
  State<DeviceRegistrationView> createState() => _DeviceRegistrationViewState();
}

class _DeviceRegistrationViewState extends State<DeviceRegistrationView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _obscurePassword = true;
  DeviceAuthPayload? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername;
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await Device().collectAuthDeviceInfo();
    if (mounted) setState(() => _deviceInfo = info);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(true),
          SafeArea(
            child: RepositoryProvider(
              create: (_) => DeviceRegistrationRepository(),
              child: BlocProvider(
                create: (context) =>
                    DeviceRegistrationBloc(context.read()),
                child: BlocConsumer<DeviceRegistrationBloc,
                    DeviceRegistrationState>(
                  listener: (context, state) {
                    if (state is DeviceRegistrationSuccess) {
                      _showSuccessDialog(context, state.message, state.requestId);
                    } else if (state is DeviceRegistrationStatusLoaded) {
                      context.showSnackBarMessage(
                          'Status: ${state.status} — ${state.message}');
                    } else if (state is DeviceRegistrationError) {
                      context.showSnackBarMessage(state.message);
                    }
                  },
                  builder: (context, state) {
                    final bloc = context.read<DeviceRegistrationBloc>();
                    final isLoading = state is DeviceRegistrationLoading;
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16.h),
                          Image.asset(
                            ImageConstants.logo,
                            width: 0.18.sw,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Device re-registration',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Submit a request to register this device. '
                            'Your administrator must approve before you can log in from here.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          SizedBox(height: 20.h),
                          _deviceInfoCard(context),
                          SizedBox(height: 16.h),
                          _field(
                            controller: _usernameController,
                            label: 'Username / Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 10.h),
                          _field(
                            controller: _passwordController,
                            label: 'Password (for verification)',
                            obscure: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _field(
                            controller: _reasonController,
                            label: 'Reason for device change',
                            maxLines: 3,
                            hint:
                                'e.g. Lost previous phone, device damaged, company issued new handset',
                          ),
                          SizedBox(height: 20.h),
                          CustomMaterialButton(
                            buttonText:
                                isLoading ? 'Submitting...' : 'Submit request',
                            onPressed: () {
                              if (isLoading) return;
                              context.hideKeyboard();
                              bloc.add(DeviceRegistrationSubmitEvent(
                                username: _usernameController.text,
                                password: _passwordController.text,
                                reason: _reasonController.text,
                              ));
                            },
                          ),
                          SizedBox(height: 10.h),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    bloc.add(DeviceRegistrationCheckStatusEvent(
                                        _usernameController.text));
                                  },
                            child: const Text(
                              'Check request status',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(AppPaths.login),
                            child: const Text(
                              'Back to login',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceInfoCard(BuildContext context) {
    final info = _deviceInfo;
    return Card(
      color: Colors.white.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This device',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: ColorConstants.amber,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (info == null)
              const Text('Loading device details...',
                  style: TextStyle(color: Colors.white70))
            else ...[
              _infoLine('Model', '${info.deviceBrand} ${info.deviceModel}'),
              _infoLine('OS', info.osVersion),
              _infoLine('App', info.appVersion),
              _infoLine('Platform', info.platform),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      inputFormatters: maxLines == 1
          ? [FilteringTextInputFormatter.deny(' ')]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: ColorConstants.amber,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.amber),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message, String requestId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Request submitted',
            style: TextStyle(color: Colors.green)),
        content: Text(
          requestId.isNotEmpty ? '$message\n\nRequest ID: $requestId' : message,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppPaths.login);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
