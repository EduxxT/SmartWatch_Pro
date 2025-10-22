// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Dark Theme Colors (Basado en la imagen) ---
const Color kDarkPrimaryBackground = Color(0xFF141721); 
const Color kDarkSecondaryBackground = Color(0xFF222533); 
const Color kDarkPrimaryText = Color(0xFFE5E7EB); 
const Color kDarkSecondaryText = Color(0xFFA1A1AA); 
const Color kAccentColor = Color(0xFF765FFD); // Violeta

// --- Typography (Space Grotesk) ---
final TextStyle h1Style = GoogleFonts.spaceGrotesk(
  fontSize: 28,
  fontWeight: FontWeight.w500, // Medium
  color: kDarkPrimaryText,
);

final TextStyle titleStyle = GoogleFonts.spaceGrotesk(
  fontSize: 18,
  fontWeight: FontWeight.w400, // Regular
  color: kDarkPrimaryText,
);

final TextStyle textStyle = GoogleFonts.spaceGrotesk(
  fontSize: 14,
  fontWeight: FontWeight.w400, // Regular
  color: kDarkSecondaryText, 
);