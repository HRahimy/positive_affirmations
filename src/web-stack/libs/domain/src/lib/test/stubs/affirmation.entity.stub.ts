import { AffirmationEntity } from '../../entity/affirmation.entity';
import { userStub } from './user.entity.stub';

export const affirmationStub = (): AffirmationEntity => {
  return new AffirmationEntity({
    id: 123,
    uiId: '123',
    title: 'test affirmation',
    active: true,
    createdBy: userStub(),
    createdOn: new Date(Date.now().toLocaleString()),
    likes: [],
    reaffirmations: [],
  });
};
