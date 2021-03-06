import {
  IsDefined,
  IsEmail,
  IsOptional,
  IsString,
  Length,
} from 'class-validator';

export class SignUpCommandDto {
  @IsDefined()
  @IsEmail()
  email: string;

  @IsDefined()
  @IsString()
  @Length(3, 30)
  password: string;

  @IsDefined()
  @IsString()
  displayName: string;

  @IsString()
  @IsOptional()
  nickName?: string;

  constructor(args: {
    email: string;
    password: string;
    displayName: string;
    nickName?: string;
  }) {
    Object.assign(this, args);
  }
}
