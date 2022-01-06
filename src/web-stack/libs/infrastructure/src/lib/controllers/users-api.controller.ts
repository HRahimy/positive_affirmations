import {ApiTags} from "@nestjs/swagger";
import {Body, Controller, Post} from "@nestjs/common";
import {UsersApiFacade} from "../service/users-api.facade";
import {SignUpCommandDto} from "@web-stack/domain";

@ApiTags('users')
@Controller('users')
export class UsersApiController {
  constructor(private facade: UsersApiFacade) {
  }

  @Post()
  async signUpUser(@Body() dto: SignUpCommandDto): Promise<void> {
    return await this.facade.signUpUser(dto);
  }
}
