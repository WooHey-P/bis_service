import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcons {
  // Bus SVG icon
  static Widget busIcon({
    double size = 24,
    Color color = Colors.blue,
    String? routeNumber,
  }) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Bus SVG
          SvgPicture.string(
            '''
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="busGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:${_colorToHex(color.withOpacity(0.9))};stop-opacity:1" />
                  <stop offset="100%" style="stop-color:${_colorToHex(color)};stop-opacity:1" />
                </linearGradient>
              </defs>
              <!-- Bus body -->
              <rect x="3" y="6" width="18" height="10" rx="2" ry="2" fill="url(#busGradient)" stroke="white" stroke-width="0.5"/>
              <!-- Windows -->
              <rect x="4" y="7" width="4" height="3" rx="0.5" fill="rgba(255,255,255,0.9)"/>
              <rect x="9" y="7" width="6" height="3" rx="0.5" fill="rgba(255,255,255,0.9)"/>
              <rect x="16" y="7" width="4" height="3" rx="0.5" fill="rgba(255,255,255,0.9)"/>
              <!-- Door -->
              <rect x="8.5" y="11" width="1" height="4" fill="rgba(0,0,0,0.3)"/>
              <!-- Wheels -->
              <circle cx="6" cy="17" r="1.5" fill="#333" stroke="white" stroke-width="0.3"/>
              <circle cx="18" cy="17" r="1.5" fill="#333" stroke="white" stroke-width="0.3"/>
              <!-- Wheel details -->
              <circle cx="6" cy="17" r="0.8" fill="#666"/>
              <circle cx="18" cy="17" r="0.8" fill="#666"/>
              <!-- Front lights -->
              <circle cx="21.5" cy="9" r="0.8" fill="#FFE082"/>
              <circle cx="21.5" cy="13" r="0.8" fill="#FF5722"/>
            </svg>
            ''',
            width: size,
            height: size,
          ),
          // Route number overlay
          if (routeNumber != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  routeNumber,
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Bus stop SVG icon
  static Widget busStopIcon({
    double size = 24,
    Color color = Colors.green,
    String? stationName,
  }) {
    return Container(
      width: size,
      height: size * 1.2,
      child: Stack(
        children: [
          // Bus stop SVG
          SvgPicture.string(
            '''
            <svg viewBox="0 0 24 30" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="stopGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:${_colorToHex(color.withOpacity(0.9))};stop-opacity:1" />
                  <stop offset="100%" style="stop-color:${_colorToHex(color)};stop-opacity:1" />
                </linearGradient>
              </defs>
              <!-- Pole -->
              <rect x="11" y="8" width="2" height="20" fill="#666" stroke="white" stroke-width="0.3"/>
              <!-- Sign -->
              <rect x="4" y="4" width="16" height="8" rx="1" ry="1" fill="url(#stopGradient)" stroke="white" stroke-width="0.5"/>
              <!-- Bus icon on sign -->
              <rect x="6" y="6" width="6" height="3" rx="0.5" fill="white" opacity="0.9"/>
              <circle cx="7" cy="10" r="0.5" fill="white"/>
              <circle cx="11" cy="10" r="0.5" fill="white"/>
              <!-- Text area -->
              <rect x="13" y="6" width="5" height="4" rx="0.3" fill="rgba(255,255,255,0.8)"/>
              <!-- Base -->
              <ellipse cx="12" cy="28" rx="3" ry="1" fill="#999" opacity="0.6"/>
            </svg>
            ''',
            width: size,
            height: size * 1.2,
          ),
          // Station name overlay
          if (stationName != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  stationName,
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to convert Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
