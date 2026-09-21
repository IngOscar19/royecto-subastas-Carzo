// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure()';
}


}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EmailAlreadyExists value)?  emailAlreadyExists,TResult Function( _InvalidCredentials value)?  invalidCredentials,TResult Function( _Validation value)?  validation,TResult Function( _Connection value)?  connection,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _Validation() when validation != null:
return validation(_that);case _Connection() when connection != null:
return connection(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EmailAlreadyExists value)  emailAlreadyExists,required TResult Function( _InvalidCredentials value)  invalidCredentials,required TResult Function( _Validation value)  validation,required TResult Function( _Connection value)  connection,}){
final _that = this;
switch (_that) {
case _EmailAlreadyExists():
return emailAlreadyExists(_that);case _InvalidCredentials():
return invalidCredentials(_that);case _Validation():
return validation(_that);case _Connection():
return connection(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EmailAlreadyExists value)?  emailAlreadyExists,TResult? Function( _InvalidCredentials value)?  invalidCredentials,TResult? Function( _Validation value)?  validation,TResult? Function( _Connection value)?  connection,}){
final _that = this;
switch (_that) {
case _EmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _Validation() when validation != null:
return validation(_that);case _Connection() when connection != null:
return connection(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  emailAlreadyExists,TResult Function()?  invalidCredentials,TResult Function( String message)?  validation,TResult Function()?  connection,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists();case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _Validation() when validation != null:
return validation(_that.message);case _Connection() when connection != null:
return connection();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  emailAlreadyExists,required TResult Function()  invalidCredentials,required TResult Function( String message)  validation,required TResult Function()  connection,}) {final _that = this;
switch (_that) {
case _EmailAlreadyExists():
return emailAlreadyExists();case _InvalidCredentials():
return invalidCredentials();case _Validation():
return validation(_that.message);case _Connection():
return connection();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  emailAlreadyExists,TResult? Function()?  invalidCredentials,TResult? Function( String message)?  validation,TResult? Function()?  connection,}) {final _that = this;
switch (_that) {
case _EmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists();case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _Validation() when validation != null:
return validation(_that.message);case _Connection() when connection != null:
return connection();case _:
  return null;

}
}

}

/// @nodoc


class _EmailAlreadyExists extends AuthFailure {
  const _EmailAlreadyExists(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailAlreadyExists);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emailAlreadyExists()';
}


}




/// @nodoc


class _InvalidCredentials extends AuthFailure {
  const _InvalidCredentials(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidCredentials);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.invalidCredentials()';
}


}




/// @nodoc


class _Validation extends AuthFailure {
  const _Validation(this.message): super._();
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationCopyWith<_Validation> get copyWith => __$ValidationCopyWithImpl<_Validation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Validation&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.validation(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ValidationCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$ValidationCopyWith(_Validation value, $Res Function(_Validation) _then) = __$ValidationCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ValidationCopyWithImpl<$Res>
    implements _$ValidationCopyWith<$Res> {
  __$ValidationCopyWithImpl(this._self, this._then);

  final _Validation _self;
  final $Res Function(_Validation) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Validation(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Connection extends AuthFailure {
  const _Connection(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.connection()';
}


}




// dart format on
