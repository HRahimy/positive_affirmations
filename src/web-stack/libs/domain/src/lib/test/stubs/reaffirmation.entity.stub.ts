import { ReaffirmationEntity } from '../../entity/reaffirmation.entity';
import {
  ReaffirmationFont,
  ReaffirmationStamp,
  ReaffirmationValue,
} from '@web-stack/api-interfaces';
import { userStub } from './user.entity.stub';

export const reaffirmationStub = (): ReaffirmationEntity => {
  return new ReaffirmationEntity({
    id: 123,
    uiId: '123',
    font: ReaffirmationFont.none,
    stamp: ReaffirmationStamp.empty,
    value: ReaffirmationValue.empty,
    createdBy: userStub(),
    createdOn: new Date(Date.now().toLocaleString()),
    inLetters: [],
    forAffirmation: null,
  });
};
