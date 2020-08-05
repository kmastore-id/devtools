// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../common_widgets.dart';
import '../config_specific/drag_and_drop/drag_and_drop.dart';
import '../theme.dart';
import '../ui/label.dart';
import '../utils.dart';

class FileImportContainer extends StatefulWidget {
  const FileImportContainer({
    @required this.title,
    @required this.instructions,
    this.actionText,
    this.onAction,
    this.onFileSelected,
    Key key,
  }) : super(key: key);

  final String title;

  final String instructions;

  /// The title of the action button.
  final String actionText;

  final DevToolsJsonFileHandler onAction;

  final DevToolsJsonFileHandler onFileSelected;

  @override
  _FileImportContainerState createState() => _FileImportContainerState();
}

class _FileImportContainerState extends State<FileImportContainer> {
  DevToolsJsonFile importedFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18.0),
        ),
        const SizedBox(height: defaultSpacing),
        Expanded(
          // TODO(kenz): improve drag over highlight.
          child: DragAndDrop(
            handleDrop: _handleImportedFile,
            child: RoundedOutlinedBorder(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImportInstructions(),
                    _buildImportFileRow(),
                    if (widget.actionText != null && widget.onAction != null)
                      _buildActionButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportInstructions() {
    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
      child: Text(
        widget.instructions,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline1.color,
        ),
      ),
    );
  }

  Widget _buildImportFileRow() {
    const rowHeight = 37.0;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Horizontal spacer with flex value of 1.
        const Flexible(
          child: SizedBox(height: rowHeight),
        ),
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: Container(
            height: rowHeight,
            padding: const EdgeInsets.all(denseSpacing),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.focusColor),
                bottom: BorderSide(color: theme.focusColor),
                left: BorderSide(color: theme.focusColor),
              ),
            ),
            child: _buildImportedFileDisplay(),
          ),
        ),
        _buildImportButton(),
        // Horizontal spacer with flex value of 1.
        const Flexible(
          child: SizedBox(height: rowHeight),
        ),
      ],
    );
  }

  Widget _buildImportedFileDisplay() {
    return Text(
      importedFile?.path ?? 'No File Selected',
      style: TextStyle(
        color: Theme.of(context).textTheme.headline1.color,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildImportButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlineButton(
          onPressed: () {},
          child: const MaterialIconLabel(Icons.file_upload, 'Import File'),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: defaultSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: importedFile != null
                  ? () => widget.onAction(importedFile)
                  : null,
              child: MaterialIconLabel(
                Icons.highlight,
                widget.actionText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // TODO(kenz): add error handling to ensure we only allow importing supported
  // files.
  void _handleImportedFile(DevToolsJsonFile file) {
    setState(() {
      importedFile = file;
    });
    if (widget.onFileSelected != null) {
      widget.onFileSelected(file);
    }
  }
}

class DualFileImportContainer extends StatefulWidget {
  const DualFileImportContainer({
    @required this.firstFileTitle,
    @required this.secondFileTitle,
    @required this.firstInstructions,
    @required this.secondInstructions,
    @required this.actionText,
    @required this.onAction,
    Key key,
  });

  final String firstFileTitle;

  final String secondFileTitle;

  final String firstInstructions;

  final String secondInstructions;

  /// The title of the action button.
  final String actionText;

  final Function(
    DevToolsJsonFile firstImportedFile,
    DevToolsJsonFile secondImportedFile,
  ) onAction;

  @override
  _DualFileImportContainerState createState() =>
      _DualFileImportContainerState();
}

class _DualFileImportContainerState extends State<DualFileImportContainer> {
  DevToolsJsonFile firstImportedFile;
  DevToolsJsonFile secondImportedFile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FileImportContainer(
            title: widget.firstFileTitle,
            instructions: widget.firstInstructions,
            onFileSelected: onFirstFileSelected,
          ),
        ),
        const SizedBox(width: defaultSpacing),
        Center(child: _buildActionButton()),
        const SizedBox(width: defaultSpacing),
        Expanded(
          child: FileImportContainer(
            title: widget.secondFileTitle,
            instructions: widget.secondInstructions,
            onFileSelected: onSecondFileSelected,
          ),
        ),
      ],
    );
  }

  void onFirstFileSelected(DevToolsJsonFile selectedFile) {
    setState(() {
      firstImportedFile = selectedFile;
    });
  }

  void onSecondFileSelected(DevToolsJsonFile selectedFile) {
    setState(() {
      secondImportedFile = selectedFile;
    });
  }

  Widget _buildActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: defaultSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: firstImportedFile != null && secondImportedFile != null
                  ? () => widget.onAction(firstImportedFile, secondImportedFile)
                  : null,
              child: MaterialIconLabel(
                Icons.highlight,
                widget.actionText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}