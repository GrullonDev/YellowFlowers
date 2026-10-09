// Global constants used across the app

import 'package:flutter/material.dart';

/// Destination URL encoded into the QR code on the Story card.
const String kQrCodeUrl = 'https://jorgegrullondev.com/';

/// Beta tester signup sheet, opened from the "Únete a la Beta" tile.
const String kBetaSignupUrl =
    'https://docs.google.com/spreadsheets/d/14H5Gsgb_rATcTGrvAOZouG95nfpafivRkpDNhbC5BFU/edit?usp=sharing';

/// Target resolution for every exported/shared card image: a full-bleed
/// Instagram/WhatsApp Story (9:16).
const double kShareImageWidth = 1080;
const double kShareImageHeight = 1920;

/// Background shown behind a share card when it's smaller than the fixed
/// export canvas, matching the dark frame the share cards paint themselves.
const Color kShareCanvasBackground = Color(0xFF0B0820);
