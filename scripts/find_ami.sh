aws ec2 describe-images \
    --filters 'Name=name,Values=al2023-ami-2023.*' \
    --filters 'Name=architecture,Values=arm64' \
    --filters 'Name=ena-support,Values=true' \
    --filters 'Name=virt-type,Values=hvm'
