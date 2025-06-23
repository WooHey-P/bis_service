import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcons {
  // Professional Bus SVG icon
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
          // Enhanced Bus SVG
          SvgPicture.string(
            '''
            <svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="busGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:${_colorToHex(color.withOpacity(0.95))};stop-opacity:1" />
                  <stop offset="50%" style="stop-color:${_colorToHex(color)};stop-opacity:1" />
                  <stop offset="100%" style="stop-color:${_colorToHex(color.withOpacity(0.8))};stop-opacity:1" />
                </linearGradient>
                <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
                  <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.2)"/>
                </filter>
              </defs>
              <!-- Bus body with shadow -->
              <rect x="4" y="8" width="24" height="14" rx="3" ry="3" fill="url(#busGradient)" stroke="white" stroke-width="0.8" filter="url(#shadow)"/>
              <!-- Front windshield -->
              <rect x="5.5" y="9.5" width="5" height="4" rx="0.8" fill="rgba(255,255,255,0.95)" stroke="rgba(0,0,0,0.1)" stroke-width="0.3"/>
              <!-- Side windows -->
              <rect x="12" y="9.5" width="8" height="4" rx="0.8" fill="rgba(255,255,255,0.95)" stroke="rgba(0,0,0,0.1)" stroke-width="0.3"/>
              <rect x="21.5" y="9.5" width="5" height="4" rx="0.8" fill="rgba(255,255,255,0.95)" stroke="rgba(0,0,0,0.1)" stroke-width="0.3"/>
              <!-- Door -->
              <rect x="11" y="15" width="1.5" height="6" fill="rgba(0,0,0,0.4)" rx="0.3"/>
              <!-- Wheels with better design -->
              <circle cx="8" cy="23" r="2.2" fill="#2C3E50" stroke="white" stroke-width="0.5"/>
              <circle cx="24" cy="23" r="2.2" fill="#2C3E50" stroke="white" stroke-width="0.5"/>
              <circle cx="8" cy="23" r="1.3" fill="#34495E"/>
              <circle cx="24" cy="23" r="1.3" fill="#34495E"/>
              <circle cx="8" cy="23" r="0.6" fill="#7F8C8D"/>
              <circle cx="24" cy="23" r="0.6" fill="#7F8C8D"/>
              <!-- Front lights -->
              <circle cx="29" cy="11" r="1" fill="#FFF176" stroke="rgba(0,0,0,0.2)" stroke-width="0.3"/>
              <circle cx="29" cy="17" r="1" fill="#FF7043" stroke="rgba(0,0,0,0.2)" stroke-width="0.3"/>
              <!-- Route number display -->
              <rect x="13" y="16" width="6" height="3" rx="0.5" fill="rgba(0,0,0,0.8)"/>
            </svg>
            ''',
            width: size,
            height: size,
          ),
          // Professional route number overlay
          if (routeNumber != null)
            Positioned(
              bottom: size * 0.15,
              left: size * 0.35,
              right: size * 0.35,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.05,
                  vertical: size * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.08),
                  border: Border.all(color: color, width: size * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: size * 0.1,
                      offset: Offset(0, size * 0.02),
                    ),
                  ],
                ),
                child: Text(
                  routeNumber,
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Professional Bus Stop SVG icon
  static Widget busStopIcon({
    double size = 24,
    Color color = Colors.green,
    String? stationName,
  }) {
    return Container(
      width: size,
      height: size * 1.3,
      child: Stack(
        children: [
          // Enhanced Bus Stop SVG
          SvgPicture.string(
            '''
            <svg viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="stopGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:${_colorToHex(color.withOpacity(0.95))};stop-opacity:1" />
                  <stop offset="50%" style="stop-color:${_colorToHex(color)};stop-opacity:1" />
                  <stop offset="100%" style="stop-color:${_colorToHex(color.withOpacity(0.8))};stop-opacity:1" />
                </linearGradient>
                <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
                  <feDropShadow dx="0" dy="2" stdDeviation="3" flood-color="rgba(0,0,0,0.25)"/>
                </filter>
              </defs>
              <!-- Pole with gradient -->
              <rect x="15" y="12" width="2.5" height="26" fill="url(#stopGradient)" stroke="white" stroke-width="0.5" rx="1.25"/>
              <!-- Main sign with professional design -->
              <rect x="6" y="6" width="20" height="12" rx="2" ry="2" fill="url(#stopGradient)" stroke="white" stroke-width="0.8" filter="url(#shadow)"/>
              <!-- Bus icon on sign -->
              <rect x="8" y="8.5" width="8" height="4" rx="1" fill="rgba(255,255,255,0.95)" stroke="rgba(0,0,0,0.1)" stroke-width="0.3"/>
              <circle cx="9.5" cy="13.5" r="0.8" fill="rgba(255,255,255,0.9)"/>
              <circle cx="14.5" cy="13.5" r="0.8" fill="rgba(255,255,255,0.9)"/>
              <!-- Information display -->
              <rect x="17.5" y="8.5" width="6.5" height="7" rx="0.8" fill="rgba(255,255,255,0.9)" stroke="rgba(0,0,0,0.1)" stroke-width="0.3"/>
              <!-- Digital display lines -->
              <rect x="18.5" y="10" width="4.5" height="0.8" rx="0.2" fill="rgba(0,0,0,0.7)"/>
              <rect x="18.5" y="11.5" width="3.5" height="0.8" rx="0.2" fill="rgba(0,0,0,0.5)"/>
              <rect x="18.5" y="13" width="4" height="0.8" rx="0.2" fill="rgba(0,0,0,0.6)"/>
              <!-- Base with shadow -->
              <ellipse cx="16" cy="37" rx="4.5" ry="1.5" fill="rgba(0,0,0,0.2)"/>
              <ellipse cx="16" cy="36.5" rx="3.5" ry="1" fill="#7F8C8D"/>
            </svg>
            ''',
            width: size,
            height: size * 1.3,
          ),
          // Professional station name overlay
          if (stationName != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.1,
                  vertical: size * 0.05,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.15),
                  border: Border.all(color: color, width: size * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: size * 0.15,
                      offset: Offset(0, size * 0.05),
                    ),
                  ],
                ),
                child: Text(
                  stationName,
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.3,
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
