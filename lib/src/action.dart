sealed class ResumeLockAction {
  const ResumeLockAction._();

  const factory ResumeLockAction.lock() = ResumeLockActionLock._;
}

class ResumeLockActionLock extends ResumeLockAction {
  const ResumeLockActionLock._() : super._();
}
