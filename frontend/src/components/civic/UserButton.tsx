import React from 'react'
import { UserButton as CivicUserButton } from '@civic/auth-web3/react'

interface UserButtonProps {
  className?: string
  dropdownButtonClassName?: string
  style?: React.CSSProperties
  dropdownButtonStyle?: React.CSSProperties
}

export const UserButton: React.FC<UserButtonProps> = ({
  className,
  dropdownButtonClassName,
  style,
  dropdownButtonStyle,
}) => {
  return (
    <CivicUserButton
      className={className}
      dropdownButtonClassName={dropdownButtonClassName}
      style={style}
      dropdownButtonStyle={dropdownButtonStyle}
    />
  )
} 