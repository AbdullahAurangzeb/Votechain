import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// VoteChain icon tokens — Material Symbols Rounded equivalents via [Icons].
///
/// Icon *colors* come from [Theme.of(context).colorScheme] or [AppColorsExtension].
/// This file defines sizes and semantic [IconData] mappings only.
abstract final class AppIcons {
  // ── Sizes ────────────────────────────────────────────────────────────────
  static const double sizeDefault = 24;
  static const double sizeDense = 20;
  static const double sizeSmall = 18;
  static const double sizeLarge = 32;

  static const double iconTextGap = AppSpacing.iconTextGap;

  // ── Brand & security ─────────────────────────────────────────────────────
  static const IconData shield = Icons.shield_outlined;
  static const IconData verifiedUser = Icons.verified_user_outlined;

  // ── Voting & elections ───────────────────────────────────────────────────
  static const IconData howToVote = Icons.how_to_vote_outlined;
  static const IconData ballot = Icons.ballot_outlined;
  static const IconData accountBalance = Icons.account_balance_outlined;

  // ── Identity & biometrics ──────────────────────────────────────────────────
  static const IconData face = Icons.face_outlined;
  static const IconData faceRetouching = Icons.face_retouching_natural_outlined;
  static const IconData badge = Icons.badge_outlined;
  static const IconData creditCard = Icons.credit_card_outlined;
  static const IconData documentScanner = Icons.document_scanner_outlined;

  // ── Blockchain ───────────────────────────────────────────────────────────
  static const IconData link = Icons.link_rounded;
  static const IconData hub = Icons.hub_outlined;
  static const IconData receiptLong = Icons.receipt_long_outlined;

  // ── Navigation ───────────────────────────────────────────────────────────
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home_rounded;
  static const IconData person = Icons.person_outline_rounded;
  static const IconData personFilled = Icons.person_rounded;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData notificationsFilled = Icons.notifications_rounded;

  // ── Actions ──────────────────────────────────────────────────────────────
  static const IconData checkCircle = Icons.check_circle_outline_rounded;
  static const IconData checkCircleFilled = Icons.check_circle_rounded;
  static const IconData contentCopy = Icons.content_copy_rounded;
  static const IconData arrowBack = Icons.arrow_back_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData moreVert = Icons.more_vert_rounded;

  // ── Status ───────────────────────────────────────────────────────────────
  static const IconData error = Icons.error_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData pending = Icons.hourglass_empty_rounded;

  // ── Auth form ────────────────────────────────────────────────────────────
  static const IconData mail = Icons.mail_outline_rounded;
  static const IconData call = Icons.call_outlined;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData arrowForward = Icons.arrow_forward_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData shieldLock = Icons.enhanced_encryption_outlined;
}
