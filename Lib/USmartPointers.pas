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
{$IF CompilerVersion >= 34.0}  // CMR is supported from 10.4 Sydney
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
{$ENDIF}
{$ENDREGION}

{$REGION 'SmartPointer3 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Shared Reference Count.'}
{$IF CompilerVersion >= 34.0}
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
{$ENDIF}
{$ENDREGION}

{$REGION 'SmartPointer4 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Monitor Hack.'}
{$IF CompilerVersion >= 34.0}
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
{$ENDIF}
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

{$REGION 'SmartPointer6 / Smart Pointer implementation using a combination of interface and record.'}
  ISmartPointer6 = interface
  ['{CE522D5D-41DE-4C6F-BC84-912C2AEF66B3}']
  end;

  TSmart = class(TInterfacedObject, ISmartPointer6)
  private
    FObject: TObject;
  public
    constructor Create(AObject: TObject);
    destructor Destroy; override;
  end;

  SmartPointer6<T: class> = record
  private
    FGuard: ISmartPointer6;
    FGuardedObject: T;
  public
    class operator Implicit(GuardedObject: T): SmartPointer6<T>;
    class operator Implicit(Guard: SmartPointer6<T>): T;
  end;
{$ENDREGION}

{$REGION 'SmartPointer7 / Another Smart Pointer implementation using a combination of interface and record.'}
  TLifetimeWatcher = class(TInterfacedObject)
  private
    FWhenDone: TProc;
  public
    constructor Create(const AWhenDone: TProc);
    destructor Destroy; override;
    function Birthday: string;
  end;

  TSmartPointer7<T: class> = record
  strict private
    FValue: T;
    FLifetime: IInterface;
  public
    constructor Create(const AValue: T); overload;
    class operator Implicit(const AValue: T): TSmartPointer7<T>;
    property Value: T read FValue;
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
{$IF CompilerVersion >= 34.0}
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
{$ENDIF}
{$ENDREGION}

{$REGION 'SmartPointer3 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Shared Reference Count.'}
{$IF CompilerVersion >= 34.0}
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
{$ENDIF}
{$ENDREGION}

{$REGION 'SmartPointer4 / Smart Pointer implementation Using a CMR(Custom Managed Record) with a Monitor Hack.'}
{$IF CompilerVersion >= 34.0}
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
{$ENDIF}
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

{$REGION 'SmartPointer6 / Smart Pointer implementation using a combination of interface and record.'}

{ TGuard }
constructor TSmart.Create(AObject: TObject);
begin
  FObject := AObject;
end;

destructor TSmart.Destroy;
begin
  FObject.Free;
  inherited;
end;

{ SmartGuard<T> }
class operator SmartPointer6<T>.Implicit(Guard: SmartPointer6<T>): T;
begin
  Result := Guard.FGuardedObject;
end;

class operator SmartPointer6<T>.Implicit(GuardedObject: T): SmartPointer6<T>;
begin
  Result.FGuard := TSmart.Create(GuardedObject);
  Result.FGuardedObject := GuardedObject;
end;
{$ENDREGION}

{$REGION 'Smart pointer 7/ Another Smart Pointer implementation using a combination of interface and record.'}
{ TLifetimeWatcher }
function TLifetimeWatcher.Birthday: string;
begin
  Result := 'My birthday is november 01 2000';
end;

constructor TLifetimeWatcher.Create(const AWhenDone: TProc);
begin
  FWhenDone := AWhenDone;
end;

destructor TLifetimeWatcher.Destroy;
begin
  if Assigned(FWhenDone) then
    FWhenDone;

  inherited;
end;

{ TSmartPointer7<T> }
constructor TSmartPointer7<T>.Create(const AValue: T);
begin
 FValue := AValue;
  FLifetime := TLifetimeWatcher.Create(procedure
  begin
    AValue.Free;
  end);
end;

class operator TSmartPointer7<T>.Implicit(const AValue: T): TSmartPointer7<T>;
begin
  Result := TSmartPointer7<T>.Create(AValue);
end;
{$ENDREGION}
end.
