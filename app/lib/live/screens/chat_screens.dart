library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../api/api_config.dart';
import '../../api/api_client.dart';
import '../../api/auth_store.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

/// 聊天相关页面：会话列表 / 单聊 / 群聊设置与成员管理 / 添加好友 / 聊天信息 / 拉黑管理。
///
/// 单文件曾达 4700+ 行，按功能拆分为多个 part 共享私有辅助类：
///   - chat_conversation_list.dart  会话列表
///   - chat_conversation.dart       单聊（语音、气泡、附件面板）
///   - chat_group.dart              群设置、成员管理、解散/转让
///   - chat_misc.dart               添加好友、聊天信息、拉黑列表
part 'chat_conversation_list.dart';
part 'chat_conversation.dart';
part 'chat_group.dart';
part 'chat_misc.dart';
