enum PackageItemType {
  image,
  movieClip,
  sound,
  component,
  atlas,
  font,
  swf,
  misc,
  unknown,
  spine,
  dragonBones
}

enum ObjectType {
  image,
  movieClip,
  swf,
  graph,
  loader,
  group,
  text,
  richText,
  inputText,
  component,
  list,
  label,
  button,
  comboBox,
  progressBar,
  slider,
  scrollBar,
  tree,
  loader3d
}

enum ButtonMode { common, check, radio }

enum ChildrenRenderOrder { ascent, descent, arch }

enum OverflowType { visible, hidden, scroll }

enum ScrollType { horizontal, vertical, both }

enum ScrollBarDisplayType { defaultType, visible, auto, hidden }

enum LoaderFillType {
  none,
  scale,
  scaleMatchHeight,
  scaleMatchWidth,
  scaleFree,
  scaleNoBorder
}

enum ProgressTitleType { percent, valueMax, value, max }

enum ListLayoutType {
  singleColumn,
  singleRow,
  flowHorizontal,
  flowVertical,
  pagination
}

enum ListSelectionMode { single, multiple, multipleSingleClick, none }

enum GroupLayoutType { none, horizontal, vertical }

enum PopupDirection { auto, up, down }

enum AutoSizeType { none, both, height, shrink }

enum FlipType { none, horizontal, vertical, both }

enum TransitionActionType {
  xy,
  size,
  scale,
  pivot,
  alpha,
  rotation,
  color,
  animation,
  visible,
  sound,
  transition,
  shake,
  colorFilter,
  skew,
  text,
  icon,
  unknown
}

enum FillMethod {
  none,
  horizontal,
  vertical,
  radial90,
  radial180,
  radial360
}

enum FillOrigin { top, bottom, left, right }

enum ObjectPropID {
  text,
  icon,
  color,
  outlineColor,
  playing,
  frame,
  deltaTime,
  timescale,
  fontSize,
  selected
}
