# Protobuf Workflow (Buf)

We've abandoned `protoc` shell scripts in favor of **Buf** (`bufbuild`) for managing our protobuf definitions in `0_ath_proto`.

## Why Buf?
- No messy shell scripts.
- Built-in linting (`buf lint`).
- Handles complex pathing and Go modules natively.

## Structure
- `buf.yaml`: Workspace definition and linting rules.
- `buf.gen.yaml`: Generates the Go (`protoc-gen-go`) and gRPC (`protoc-gen-go-grpc`) stubs.

## How to Compile
Whenever you add or change a `.proto` file, simply open `0_ath_proto` in your terminal and run:
```powershell
buf generate
```
Buf will automatically parse `buf.gen.yaml` and place all `.pb.go` files in the exact module paths specified.
