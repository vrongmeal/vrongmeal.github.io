---
title: Custom Errors in Go
category: tech
excerpt: >-
    A story about `error`s in Go and how can you customize it.
---

The Go `error` is nothing but an interface implementing `Error() string` method.

```go
type error interface{
    Error() string
}
```

So if we want to create an error, we can simply create a struct, say, `ImplementError`, like so:

```go
type ImplementError struct{
    Value string
}
```

and now make the `*ImplementError` implement the `error` interface.

```go
func (e *ImplementError) Error() string {
    return e.Value
}
```

To create a new `error`, we now just need to set value variable of type `error` to an `*ImplementError` with our error value or create a function that takes the value as parameter and returns an `error`.

```go
var err error

err = &ImplementError{
    Value: "my error",
}

// OR

func NewError(value string) error {
    return &ImplementError{
        Value: value,
    }
}

err = NewError("my error")
```

The `"errors"` package does the same so we don't have to repeat the process. The `errors.New` function is same as our `NewError` function. But knowing the whole process isn't a waste. This is going to help us in creating our own error type.

## Why do we need a custom error type?

Simply because with Go `error` I can only store a string and no other value.

Say, I want my error to store a code and a message. I can define `MyError` as:

```go
type MyError struct{
    Code    int
    Message string
}
```

This might work for a small project that is only going to be used by us but we do have to keep this in mind that any function that returns an error is of `error` type. Every Go codebase follows this pattern. We shouldn't break this. Let's make our type implement the `error` interface.

```go
func (e *MyError) Error() string {
    return fmt.Sprintf("%d: %s", e.Code, e.Message)
}
```

We should also create a function that takes the code and the message as parameters and returns an `error`.

```go
func NewMyError(code int, message string) {
    return &MyError{
        Code:    code,
        Message: message,
    }
}
```

## Wait! What?

> I still cannot access the code and the message explicitly. All I have is another `error`. I could have done this just by creating new error as `errors.New(fmt.Sprintf("%d: %s", code, message))`. I did not need another type!

This is where the first thing we learnt about `error`s comes in handy. It is an interface. We can assert any type on it. Say a function Xyz that returns an `error` on failure.

```go
func Xyz() error {
    ...
    if ... {
        return NewMyError(123, "my error")
    }
    return nil
}
```

When we use the function `Xyz` in our code, we'll get an `error` on which we can assert the type `*MyError` and access the code and the message.

```go
err := Xyz()

if err != nil {
    myErr := err.(*MyError)
    // Now we can access the code by myErr.Code
    // and message by myErr.Message
    if myErr.Code == 123 {
        panic(myErr.Message)
    }
}
```

Now, if you know that your function `Xyz` isn't going to be used in any other library (example: A CLI app) or the functions in your code are not exported, you can customize make `Xyz` in this case return `*MyError`.

A better way to handle all the cases is you create an interface called `MyError` which implements the methods, say, `Code() int` and `Message() string` as well as the `Error() string` method.

Creating an interface is better because you might do this:

```go
var err error

err = Xyz()

// Now, if Xyz() returns a pointer to the struct, say `*MyError`
if err != nil { // This will always be true!
    panic(err)
}
```

This is because during compile time go has to decide what type to allot to the `nil` on the right hand side. The compiler allots the default type `error` to the `nil` whereas when we set the `err` equal to `Xyz()`, we implied that `err` has the type `*MyError`. When comparing, `err` will be not equal to the `nil` since the former and the latter have different types.

When you set an interface as `nil`, it's type and value both are set to `nil`. So when you compare a `nil` `MyError` with actual `nil`, it is true! So it all works out.

A good article explaining this, that you might want to read is -- [When nil Isn't Equal to nil](//www.calhoun.io/when-nil-isnt-equal-to-nil/)<sup>[1]</sup>.

Another great read would be [Go-tcha: When nil != nil](//dev.to/pauljlucas/go-tcha-when-nil--nil-hic)<sup>[2]</sup>.

Bottom line, use `interface`! You can assert type if it's not nil or use the same type. Just remember to add the `Error() string` and make your type implement the `error` interface.

At the end your error package should look something like this:

{% highlight go linenos %}
package myerror

import "fmt"

type MyError interface {
	error // To implement the error interface
	Code() int
	Message() string
}

type myErr struct {
	errCode int
	errMsg  string
}

func (e *myErr) Error() string {
	return fmt.Sprintf("%d: %s", e.errCode, e.errMsg)
}

func (e *myErr) Code() int {
	return e.errCode
}

func (e *myErr) Message() string {
	return e.errMsg
}

func NewMyError(code int, message string) MyError {
	return &myErr{
		errCode: code,
		errMsg:  message,
	}
}

{% endhighlight %}

## References

1. [www.calhoun.io/when-nil-isnt-equal-to-nil/](//www.calhoun.io/when-nil-isnt-equal-to-nil/)
2. [dev.to/pauljlucas/go-tcha-when-nil--nil-hic](//dev.to/pauljlucas/go-tcha-when-nil--nil-hic)
