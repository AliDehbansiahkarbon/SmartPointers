unit USmartPointers;

interface
uses
  System.SysUtils;

type
{$REGION 'SmartPointer1 / Smart Pointer implementation using Object Interfaces.'}
  ISmartPointer1<T: class> = interface
    function GetRef: T;
    property Ref: T read GetRef;
  end;

  TSmartPointer1<T: class> = class(TInterfacedObject, ISmartPointer1<T>)
    private
      FRef: T;
    protected
      function GetRef: T;
    public
      constructor Create(const ARef: T);
      destructor Destroy; override;
    end;
{$ENDREGION}

{$REGION 'SmartPointer2 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Base Class.'}
  TRefCountable = class abstract
  protected
    FRefCount: Integer;
  end;

  TSmartPointer2<T: TRefCountable> = record
  private
    FRef: T;
    procedure Retain; inline;
    procedure Release; inline;
  public
    constructor Create(const ARef: T);
    class operator Initialize(out ADest: TSmartPointer2<T>);
    class operator Finalize(var ADest: TSmartPointer2<T>);
    class operator Assign(var ADest: TSmartPointer2<T>; const [ref] ASrc: TSmartPointer2<T>);

    property Ref: T read FRef;
  end;
{$ENDREGION}

{$REGION 'SmartPointer3 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Shared Reference Count.'}
  TSmartPointer3<T: class> = record
  private
    FRef: T;
    FRefCount: PInteger;
    procedure Retain; inline;
    procedure Release; inline;
  public
    constructor Create(const ARef: T);
    class operator Initialize(out ADest: TSmartPointer3<T>);
    class operator Finalize(var ADest: TSmartPointer3<T>);
    class operator Assign(var ADest: TSmartPointer3<T>; const [ref] ASrc: TSmartPointer3<T>);

    property Ref: T read FRef;
  end;
{$ENDREGION}

{$REGION 'SmartPointer4 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Monitor Hack.'}
  TSmartPointer4<T: class> = record
  private
    FRef: T;
    function GetRefCountPtr: PInteger; inline;
    procedure Retain; inline;
    procedure Release; inline;
  public
    constructor Create(const ARef: T);
    class operator Initialize(out ADest: TSmartPointer4<T>);
    class operator Finalize(var ADest: TSmartPointer4<T>);
    class operator Assign(var ADest: TSmartPointer4<T>; const [ref] ASrc: TSmartPointer4<T>);

    property Ref: T read FRef;
  end;
{$ENDREGION}

{$REGION 'SmartPointer5 / Smart Pointer implementation using anonymouse methods.'}
  ISmartPointer5<T: class> = interface (TFunc<T>)
  end;

  TSmartPointer5<T: class> = class(TInterfacedObject, ISmartPointer5<T>)
  private
    FValue: T;
  public
    constructor Create(AValue: T);
    destructor Destroy; override;
    function Invoke: T;
  end;
{$ENDREGION}

implementation

{$REGION 'SmartPointer1 / Smart Pointer implementation using Object Interfaces.'}

constructor TSmartPointer1<T>.Create(const ARef: T);
begin
  inherited Create;
  FRef := ARef;
end;

destructor TSmartPointer1<T>.Destroy;
begin
  FRef.Free;
  inherited;
end;

function TSmartPointer1<T>.GetRef: T;
begin
  Result := FRef;
end;
{$ENDREGION}

{$REGION 'SmartPointer2 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Base Class.'}
class operator TSmartPointer2<T>.Assign(var ADest: TSmartPointer2<T>; const [ref] ASrc: TSmartPointer2<T>);
begin
  if (ADest.FRef <> ASrc.FRef) then
  begin
    ADest.Release;
    ADest.FRef := ASrc.FRef;
    ADest.Retain;
  end;
end;

constructor TSmartPointer2<T>.Create(const ARef: T);
begin
  Assert((ARef = nil) or (ARef.FRefCount = 0));
  FRef := ARef;
  Retain;
end;

class operator TSmartPointer2<T>.Finalize(var ADest: TSmartPointer2<T>);
begin
  ADest.Release;
end;

class operator TSmartPointer2<T>.Initialize(out ADest: TSmartPointer2<T>);
begin
  ADest.FRef := nil;
end;

procedure TSmartPointer2<T>.Release;
begin
  if (FRef <> nil) then
  begin
    if (AtomicDecrement(FRef.FRefCount) = 0) then
      FRef.Free;

    FRef := nil;
  end;
end;

procedure TSmartPointer2<T>.Retain;
begin
  if (FRef <> nil) then
    AtomicIncrement(FRef.FRefCount);
end;
{$ENDREGION}

{$REGION 'SmartPointer3 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Shared Reference Count.'}
class operator TSmartPointer3<T>.Assign(var ADest: TSmartPointer3<T>; const [ref] ASrc: TSmartPointer3<T>);
begin
  if (ADest.FRef <> ASrc.FRef) then
  begin
    ADest.Release;
    ADest.FRef := ASrc.FRef;
    ADest.FRefCount := ASrc.FRefCount;
    ADest.Retain;
  end;
end;

constructor TSmartPointer3<T>.Create(const ARef: T);
begin
  FRef := ARef;
  if (ARef <> nil) then
  begin
    GetMem(FRefCount, SizeOf(Integer));
    FRefCount^ := 0;
  end;
  Retain;
end;

class operator TSmartPointer3<T>.Finalize(var ADest: TSmartPointer3<T>);
begin
  ADest.Release;
end;

class operator TSmartPointer3<T>.Initialize(out ADest: TSmartPointer3<T>);
begin
  ADest.FRef := nil;
  ADest.FRefCount := nil;
end;

procedure TSmartPointer3<T>.Release;
begin
  if (FRefCount <> nil) then
  begin
    if (AtomicDecrement(FRefCount^) = 0) then
    begin
      FRef.Free;
      FreeMem(FRefCount);
    end;

    FRef := nil;
    FRefCount := nil;
  end;
end;

procedure TSmartPointer3<T>.Retain;
begin
  if (FRefCount <> nil) then
    AtomicIncrement(FRefCount^);
end;
{$ENDREGION}

{$REGION 'SmartPointer4 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Monitor Hack.'}
class operator TSmartPointer4<T>.Assign(var ADest: TSmartPointer4<T>; const [ref] ASrc: TSmartPointer4<T>);
begin
  if (ADest.FRef <> ASrc.FRef) then
  begin
    ADest.Release;
    ADest.FRef := ASrc.FRef;
    ADest.Retain;
  end;
end;

constructor TSmartPointer4<T>.Create(const ARef: T);
begin
  FRef := ARef;
  Assert((FRef = nil) or (GetRefCountPtr^ = 0));
  Retain;
end;

class operator TSmartPointer4<T>.Finalize(var ADest: TSmartPointer4<T>);
begin
  ADest.Release;
end;

function TSmartPointer4<T>.GetRefCountPtr: PInteger;
begin
  if (FRef = nil) then
    Result := nil
  else
    Result := PInteger(IntPtr(FRef) + FRef.InstanceSize - hfFieldSize + hfMonitorOffset);
end;

class operator TSmartPointer4<T>.Initialize(out ADest: TSmartPointer4<T>);
begin
  ADest.FRef := nil;
end;

procedure TSmartPointer4<T>.Release;
begin
  var RefCountPtr := GetRefCountPtr;
  if (RefCountPtr <> nil) then
  begin
    if (AtomicDecrement(RefCountPtr^) = 0) then
      FRef.Free;

    FRef := nil;
  end;
end;

procedure TSmartPointer4<T>.Retain;
begin
  var RefCountPtr := GetRefCountPtr;
  if (RefCountPtr <> nil) then
    AtomicIncrement(RefCountPtr^);
end;
{$ENDREGION}

{$REGION 'SmartPointer5 / Smart Pointer implementation using anonymouse methods.'}
constructor TSmartPointer5<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

destructor TSmartPointer5<T>.Destroy;
begin
  inherited;
  FValue.Free;
end;

function TSmartPointer5<T>.Invoke: T;
begin
  Result := FValue;
end;
{$ENDREGION}
end.
